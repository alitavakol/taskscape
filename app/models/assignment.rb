# == Schema Information
#
# Table name: assignments
#
#  id          :integer          not null, primary key
#  task_id     :integer          not null
#  assignee_id :integer          not null
#  creator_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Assignment < ApplicationRecord
  belongs_to :task
  belongs_to :assignee, class_name: "User"
  belongs_to :creator, class_name: "User", optional: true

  validates_presence_of :creator, :assignee, :task
  validates_uniqueness_of :task_id, scope: :assignee_id

  # assigned user should be a member of the supertask (the parent project/task of this task)
  before_create :create_membership_in_project
  def create_membership_in_project
    task.supertask.memberships.where(member_id: assignee_id, creator_id: creator_id).first_or_create if task.supertask
  end

  # assigned user should be a member of the task
  after_create :create_membership_in_task
  def create_membership_in_task
    task.memberships.where(member_id: assignee_id, creator_id: creator_id).first_or_create
  end

  # remove membership in all subtasks after removing their assignment from the task
  before_destroy :destroy_membership
  def destroy_membership
    task.memberships.where(member_id: assignee_id).destroy_all
  end
end
