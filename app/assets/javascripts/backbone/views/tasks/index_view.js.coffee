Taskscape.Views.Tasks ||= {}

class Taskscape.Views.Tasks.IndexView extends Backbone.View
  template: JST["backbone/templates/tasks/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (task) =>
    view = new Taskscape.Views.Tasks.TaskView({model : task})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(tasks: @collection.toJSON()))
    @addAll()

    return this
