json.extract! task, :id, :title, :description, :visibility, :status, :urgency, :importance, :effort, :due_date, :project_id, :creator_id, :x, :y, :color, :archived, :created_at, :updated_at
json.url task_url(task, format: :json)
