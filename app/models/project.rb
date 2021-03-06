# == Schema Information
#
# Table name: tasks
#
#  id           :integer          not null, primary key
#  title        :string(255)      not null
#  description  :text(65535)
#  visibility   :integer          not null
#  status       :integer
#  urgency      :integer
#  importance   :integer
#  effort       :integer
#  due_date     :datetime
#  supertask_id :integer
#  creator_id   :integer
#  x            :integer
#  y            :integer
#  color        :string(255)
#  archived     :boolean          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Project < ApplicationRecord
  self.table_name = "tasks"

  enum visibility: [:public_project, :private_project]

  belongs_to :creator, class_name: "User", optional: true

  # project members, who work in collaboration to complete subtasks of this supertask/project
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships

  # self joining to identify tasks of this supertask/project (like a manager/subordinates relationship)
  has_many :tasks, foreign_key: "supertask_id", dependent: :destroy
  belongs_to :superproject, class_name: "Project", foreign_key: 'supertask_id', optional: true

  validates_presence_of :creator, :title

  validates_associated :memberships
  accepts_nested_attributes_for :memberships, reject_if: :reject_duplicates

  after_create :make_creator_member
  def make_creator_member
    memberships.create(member_id: creator_id, creator_id: creator_id)
  end

  after_initialize :defaults
  def defaults
    self.visibility ||= :private_project
    self.archived ||= false
  end

  private

    def reject_duplicates(attributes)
      member_ids.include?(attributes[:member_id])
    end

end
