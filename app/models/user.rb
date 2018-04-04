# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  role                   :integer
#  invitation_token       :string(255)
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string(255)
#  invited_by_id          :integer
#  invitations_count      :integer          default(0)
#  avatar_file_name       :string(255)
#  avatar_content_type    :string(255)
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#

class User < ApplicationRecord
  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end

  has_attached_file :avatar, { styles: { small: "200x200#", thumb: "48x48#" } }.merge( ENV['I_AM_HEROKU'] ? { :url => "http://i.pravatar.cc/200?u=:id", default_url: "http://i.pravatar.cc/200?u=:id", escape_url: false } : { default_url: "/images/:style/missing.png" } ) # Heroku does not support file storage, so use http://pravatar.cc/ if app is hosted there

  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  before_save :defaults
  def defaults
    self.name ||= email[/[^@]+/]
  end

  # Include default devise modules. Others available are:
  devise :invitable, :database_authenticatable, :registerable, :recoverable, 
    :rememberable, :trackable, :validatable, :confirmable

  validates_presence_of :name, :email

  has_many :memberships, foreign_key: "member_id", dependent: :destroy
  has_many :projects, through: :memberships, class_name: "Project" # projects that this user is a member of

  has_many :assignments, foreign_key: "assignee_id", dependent: :destroy
  has_many :tasks, through: :assignments # tasks that this user is assigned to do

  has_many :created_projects, class_name: "Project", foreign_key: "creator_id", dependent: :nullify # projects/tasks created by this user

  # return list of users whose name/email match the specified query string
  # for client-side token-input (like jQuery token-input)
  def self.tokens(query)
    matches = where("name like ?", "%#{query}%").map { |m| { 'id' => m.id, 'name' => m.name } }
    matches += where("email like ?", "%#{query}%").map { |m| { 'id' => m.id, 'name' => m.email } }

    # if query is an email, add a token object with 
    # id equal to "<<<email>>>" to indicate that the user is not in database, and needs to be invited
    if query =~ Devise::email_regexp && ( matches.empty? || matches.select { |t| t['name'] == query }.count == 0 )
      matches += [{ id: "<<<#{query}>>>", name: "Invite and add: \"#{query}\""}]
    end

    matches.uniq { |m| m['id'] } # remove duplicate array elements
  end

  # given a collection of user ids, possibly containing an element like "<<<email>>>", 
  # this function replaces that specific email with the actual user id, 
  # after sending an invitation email for that user, and creating it in database,
  # and returns the new array of user ids
  def self.ids_from_tokens(tokens)
    # iterate through all tokens, and replace id matching "<<<email>>>" 
    # with actual database id after creating and inviting the user
    tokens.gsub!(/<<<(.+?)>>>/) {
      # create the invitation but do not send it
      user = invite!(email: $1) do |u|
        u.skip_invitation = true
      end

      # send the invitation in a parallel thread
      Thread.new(user) { |user| user.deliver_invitation }

      user.id
    }

    # convert string to integer array
    tokens.split(',').map(&:to_i)
  end

end
