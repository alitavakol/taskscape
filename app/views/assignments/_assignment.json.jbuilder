json.merge! assignment.attrs.merge assignment.assignee.attrs.slice('name')
# json.extract! assignment, :id, :task_id, :assignee_id, :creator_id, :created_at, :updated_at
# json.url assignment_url(assignment, format: :json)
