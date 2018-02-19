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
#

class User < ApplicationRecord
  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end

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

  has_many :created_projects, class_name: "Task", foreign_key: "creator_id", dependent: :nullify # projects/tasks created by this user

  def attrs
    attributes.slice('id', 'name', 'email').merge(confirmed: self.confirmed?)
  end

  protected

  def confirmation_required?
    Rails.env.production? && !admin?
  end
end
