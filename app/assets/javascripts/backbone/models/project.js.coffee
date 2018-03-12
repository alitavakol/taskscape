class Taskscape.Models.Project extends Backbone.RelationalModel
  paramRoot: 'project'
  urlRoot: 'projects'

  defaults:
    title: null

  relations: [
    type: 'HasMany',
    key: 'tasks'
    relatedModel: 'Taskscape.Models.Task'
    collectionType: Taskscape.Collections.TasksCollection
    includeInJSON: true
    reverseRelation:
      key: 'supertask_id'
      includeInJSON: 'id'
  ,
    type: 'HasMany',
    key: 'memberships'
    relatedModel: 'Taskscape.Models.Membership'
    collectionType: Taskscape.Collections.MembershipsCollection
    includeInJSON: true
    reverseRelation:
      key: 'project_id'
      includeInJSON: 'id'
  ,
    type: 'HasMany',
    key: 'members'
    relatedModel: 'Taskscape.Models.User'
    collectionType: Taskscape.Collections.UsersCollection
    includeInJSON: true
    reverseRelation:
      key: 'project_id'
      includeInJSON: 'id'
  ]

Taskscape.Models.Project.setup()
