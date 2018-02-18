# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  member_id  :integer          not null
#  creator_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Membership < ApplicationRecord
  belongs_to :project, class_name: "Task"
  belongs_to :member, class_name: "User"
  belongs_to :creator, class_name: "User"

  validates_presence_of :creator_id, :member_id, :project_id
  validates_uniqueness_of :project_id, scope: :member_id

  def attrs
    attributes.slice('id', 'project_id', 'member_id')
  end

  # un-assign all subtasks of this project from removed member
  before_destroy :destroy_assignments
  def destroy_assignments
    project.tasks.each do |t|
      t.assignments.where(assignee_id: member_id).destroy_all
    end
  end
end
