class Taskscape.Models.Assignment extends Backbone.Relational.Model
  paramRoot: 'assignment'
  urlRoot: 'assignments'

  defaults:
    task_id: null
    assignee_id: null

Taskscape.Models.Assignment.setup()
