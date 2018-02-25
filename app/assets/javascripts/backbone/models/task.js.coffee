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

  relations: [
    type: 'HasMany',
    key: 'assignments'
    relatedModel: 'Taskscape.Models.Assignment'
    collectionType: Taskscape.Collections.AssignmentsCollection
    includeInJSON: true
    reverseRelation:
      key: 'task_id'
  ,
    type: 'HasMany',
    key: 'assignees'
    relatedModel: 'Taskscape.Models.User'
    collectionType: Taskscape.Collections.AssignmentsCollection
    includeInJSON: true
    reverseRelation:
      key: 'task_id'
  ]

Taskscape.Models.Task.setup()
