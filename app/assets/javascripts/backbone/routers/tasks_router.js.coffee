class Taskscape.Routers.TasksRouter extends Backbone.Router
  initialize: (options) ->
    @tasks = new Taskscape.Collections.TasksCollection()
    @tasks.reset options.tasks if options?

  routes:
    "index"    : "index"
    ":id"      : "show"
    ".*"       : "index"

  index: ->
    Backbone.Relational.store.reset()
    @tasks ?= new Taskscape.Collections.TasksCollection()
    @tasks.fetch
      success: (c) ->
        view = new Taskscape.Views.Tasks.IndexView(collection: c)
        $("#tasks").html(view.render().el)

    @view = new Taskscape.Views.Tasks.IndexView(collection: @tasks)
    $("#tasks").html(@view.render().el)

  show: (id) ->
    task = Taskscape.Models.Task.find(id) ? new Taskscape.Models.Task(id: id)
    task.fetch
      success: (m) ->
        view = new Taskscape.Views.Tasks.ShowView
          model: m
          tagName: 'svg'
          attributes:
            width: "100%"
            height: "100%"

        $("#tasks").html(view.render().el)
        view.post_render()

      error: (e, f) =>
        console.log f.responseJSON
        @navigate 'index'
