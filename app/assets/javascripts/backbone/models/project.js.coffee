class Taskscape.Models.Project extends Backbone.Relational.Model
  paramRoot: 'project'
  urlRoot: 'projects'

  defaults:
    title: null

  relations: [
    type: 'HasMany',
    key: 'tasks'
    relatedModel: 'Taskscape.Models.Task'
    collectionType: Taskscape.Collections.TasksCollection
    includeInJSON: false
    reverseRelation:
      key: 'supertask_id'
  ,
    type: 'HasMany',
    key: 'memberships'
    relatedModel: 'Taskscape.Models.Membership'
    collectionType: Taskscape.Collections.MembershipsCollection
    includeInJSON: false
    reverseRelation:
      key: 'project_id'
  ]

Taskscape.Models.Project.setup()