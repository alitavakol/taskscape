class Taskscape.Models.Project extends Backbone.Relational.Model
  paramRoot: 'project'
  urlRoot: 'projects'

  defaults:
    title: null
    visibility: null
    archived: null

  relations: [
    type: 'HasMany',
    key: 'tasks'
    relatedModel: 'Taskscape.Models.Task'
    collectionType: Taskscape.Collections.TasksCollection
    includeInJSON: false
    reverseRelation:
      key: 'supertask'
      includeInJSON: 'id'
  ]

class Taskscape.Collections.ProjectsCollection extends Backbone.Collection
  model: Taskscape.Models.Project
  url: '/projects'

Taskscape.Models.Project.setup()