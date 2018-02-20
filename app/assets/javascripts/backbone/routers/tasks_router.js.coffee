class Taskscape.Routers.TasksRouter extends Backbone.Router
  initialize: (options) ->
    @tasks = new Taskscape.Collections.TasksCollection()
    @tasks.reset options.tasks

  routes:
    "new"      : "newTask"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newTask: ->
    @view = new Taskscape.Views.Tasks.NewView(collection: @tasks)
    $("#tasks").html(@view.render().el)

  index: ->
    @view = new Taskscape.Views.Tasks.IndexView(collection: @tasks)
    $("#tasks").html(@view.render().el)

  show: (id) ->
    task = @tasks.get(id)

    @view = new Taskscape.Views.Tasks.ShowView(model: task)
    $("#tasks").html(@view.render().el)

  edit: (id) ->
    task = @tasks.get(id)

    @view = new Taskscape.Views.Tasks.EditView(model: task)
    $("#tasks").html(@view.render().el)
