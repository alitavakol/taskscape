json.merge!(
  assignment.attributes.slice('id', 'assignee_id', 'task_id')
  .merge assignment.assignee.attributes.slice('name')
)
