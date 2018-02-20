class Taskscape.Models.Task extends Backbone.Relational.Model
  paramRoot: 'task'
  urlRoot: 'tasks'

  defaults:
    title: null
    description: null
    status: null
    urgency: null
    importance: null
    effort: null
    due_date: null
    x: null
    y: null
    color: null

class Taskscape.Collections.TasksCollection extends Backbone.Collection
  model: Taskscape.Models.Task
  url: '/tasks'

Taskscape.Models.Task.setup()
