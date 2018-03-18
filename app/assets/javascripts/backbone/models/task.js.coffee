class Taskscape.Models.Task extends Backbone.RelationalModel
  paramRoot: 'task'
  urlRoot: 'tasks'

  defaults:
    title: ''
    description: null
    status: 'not_started'
    urgency: 'normal_urgency'
    importance: 'normal_importance'
    effort: 'medium_effort'
    due_date: null
    x: 0
    y: 0
    color: '#5fa1e0'

  relations: [
    type: 'HasMany',
    key: 'assignments'
    relatedModel: 'Taskscape.Models.Assignment'
    collectionType: Taskscape.Collections.AssignmentsCollection
    includeInJSON: true
    reverseRelation:
      key: 'task_id'
      includeInJSON: 'id'
  ,
    type: 'HasMany',
    key: 'assignees'
    relatedModel: 'Taskscape.Models.User'
    collectionType: Taskscape.Collections.AssignmentsCollection
    includeInJSON: true
    reverseRelation:
      key: 'task_id'
      includeInJSON: 'id'
  ]

Taskscape.Models.Task.setup()
