Taskscape.Views.Tasks ||= {}

class Taskscape.Views.Tasks.TaskView extends Backbone.View
  template: JST["backbone/templates/tasks/task"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
