class Taskscape.Routers.ProjectsRouter extends Backbone.Router
  initialize: (options) ->
    @projects = new Taskscape.Collections.ProjectsCollection()
    @projects.reset options.projects if options?

  routes:
    "new"      : "newProject"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"       : "index"

  newProject: ->
    @view = new Taskscape.Views.Projects.NewView(collection: @projects)
    $("#projects").html(@view.render().el)

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

  edit: (id) ->
    project = @projects.get(id)

    @view = new Taskscape.Views.Projects.EditView(model: project)
    $("#projects").html(@view.render().el)
