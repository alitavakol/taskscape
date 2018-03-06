class Taskscape.Models.Assignment extends Backbone.RelationalModel
  paramRoot: 'assignment'
  urlRoot: 'assignments'

  defaults:
    task_id: null
    assignee_id: null

Taskscape.Models.Assignment.setup()
