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
  belongs_to :supertask, class_name: "Task"

  # task assignees
  has_many :assignments, dependent: :destroy
  has_many :assignees, through: :assignments

  enum status: [:on_hold, :not_started, :in_progress, :completed]
  enum urgency: [:low_urgency, :normal_urgency, :high_urgency, :very_high_urgency]
  enum importance: [:low_importance, :normal_importance, :high_importance, :very_high_importance]
  enum effort: [:small_effort, :medium_effort, :large_effort, :very_large_effort]

  validates_presence_of :supertask

  # avoid a supertask_id value that makes a circular reference to task itself at some point
  validate :avoid_circular_supertask, on: :update
  def avoid_circular_supertask
    t = supertask
    while t != nil
      if t.supertask_id == id
        errors.add(:supertask_id, "can't be used due to circular dependency")
        break
      end
      t = t.supertask
    end
  end

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
    r = attributes.slice('id', 'status', 'archived', 'x', 'y', 'color', 'effort', 'title', 'description', 'visibility', 'urgency', 'importance', 'due_date').merge(
      supertask: supertask_id,
      assignments: assignments.map { |r| r.attrs }
    )
    r
  end

  # returns minimal list of attributes (for index view)
  def attrs_recursive_brief
    r = attributes.slice('id', 'status', 'urgency', 'archived', 'x', 'y', 'color', 'effort', 'title').merge(
      supertask: supertask_id
    )
    r
  end

  # make it a public if parent project (supertask) is public
  after_create :set_visibility
  def set_visibility
    public_project! if supertask.public_project?
  end
end
