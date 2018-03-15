class Taskscape.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    @projects = new Taskscape.Collections.ProjectsCollection()
    @projects.reset options.projects if options?

  routes:
    "index"    : "index"
    ":id"      : "show"
    ".*"       : "index"

  index: ->
    Backbone.Relational.store.reset()
    @projects ?= new Taskscape.Collections.ProjectsCollection()
    @projects.fetch
      success: (c) ->
        view = new Taskscape.Views.Projects.IndexView(collection: c)
        $("#projects").html(view.render().el)

  show: (id) ->
    project = Taskscape.Models.Project.find(id) ? new Taskscape.Models.Project(id: id)
    project.fetch
      success: (m) ->
        view = new Taskscape.Views.Projects.ShowView(model: m)
        $("#projects").html(view.render().el)
        view.post_render()
