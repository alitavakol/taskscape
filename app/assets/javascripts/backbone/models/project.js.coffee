class Taskscape.Models.Project extends Backbone.Relational.Model
  paramRoot: 'project'
  urlRoot: 'projects'

  defaults:
    title: null

class Taskscape.Collections.ProjectsCollection extends Backbone.Collection
  model: Taskscape.Models.Project
  url: '/projects'

Taskscape.Models.Project.setup()