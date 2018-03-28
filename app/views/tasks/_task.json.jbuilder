json.merge!(
  task.attributes.slice('id', 'status', 'urgency', 'archived', 'x', 'y', 'color', 'effort', 'title', 'supertask_id', 'description', 'visibility', 'importance', 'due_date')
  .merge(
    assignments: task.assignments.map { |assignment| 
      assignment.attributes.slice('id', 'assignee_id')
      .merge assignment.assignee.attributes.slice('name')
      .merge avatar: assignment.assignee.avatar.url(:thumb)
    },
    editable: TaskPolicy.new(@current_user, task).update?
  )
)
