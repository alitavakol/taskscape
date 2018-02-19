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
#  creator_id   :integer          not null
#  x            :integer
#  y            :integer
#  color        :string(255)
#  archived     :boolean          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Task < Project
  belongs_to :supertask, class_name: "Project"

  # task assignees
  has_many :assignments, dependent: :destroy
  has_many :assignees, through: :assignments

  enum status: [:on_hold, :not_started, :in_progress, :completed]
  enum urgency: [:low_urgency, :normal_urgency, :high_urgency, :very_high_urgency]
  enum importance: [:low_importance, :normal_importance, :high_importance, :very_high_importance]
  enum effort: [:small_effort, :medium_effort, :large_effort, :very_large_effort]

  validates_presence_of :supertask_id

  after_initialize :defaults
  def defaults
    super
    self.status ||= :not_started
    self.urgency ||= :normal_urgency
    self.importance ||= :normal_importance
    self.effort ||= :medium_effort
    self.color ||= '#e5a322'
    self.x ||= 0
    self.y ||= 0
  end

  # returns attributes as a task
  def attrs_recursive
    r = attributes.slice('id', 'status', 'supertask_id', 'archived', 'x', 'y', 'color', 'effort', 'title', 'description', 'visibility', 'urgency', 'importance', 'due_date').merge(
      assignments: assignments.map { |r| r.attrs }
    )
    r
  end

  # returns minimal list of attributes (for index view)
  def attrs_recursive_brief
    attributes.slice('id', 'status', 'urgency', 'supertask_id', 'archived', 'x', 'y', 'color', 'effort', 'title')
  end

  # make it a public if parent project (supertask) is public
  after_create :set_visibility
  def set_visibility
    public_project! if supertask.public_project?
  end
end
