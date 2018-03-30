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
        # https://stackoverflow.com/a/9963360/1994239
        dispatcher.trigger('close')

        view = new Taskscape.Views.Projects.IndexView(collection: c)
        $("#projects").html(view.render().el)
        view.post_render()

  show: (id) ->
    project = Taskscape.Models.Project.find(id) ? new Taskscape.Models.Project(id: id)
    project.fetch
      success: (m) ->
        # https://stackoverflow.com/a/9963360/1994239
        dispatcher.trigger('close')

        view = new Taskscape.Views.Projects.ShowView
          model: m
          className: 'remove-gutters'
        $("#projects").html(view.render().el)
        view.post_render()

      error: (model, response, options) ->
        router.navigate 'index',
          trigger: true
          replace: true
