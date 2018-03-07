Taskscape.Views.Tasks ||= {}
Taskscape.Views.Tasks.Assignments ||= {}

class Taskscape.Views.Tasks.Assignments.IndexView extends Backbone.View
  template: JST["backbone/templates/tasks/assignments/index"]

  tagName: 'g'

  initialize: ->
    @listenTo @collection, 'add remove reset', (model, response, options) -> @render()

  addAll: ->
    @collection.forEach (assignment, idx, collection) =>
      view = new Taskscape.Views.Tasks.Assignments.AvatarView
        model: assignment
      view.task = @task

      view.rotation_coefficient = idx - (collection.length - 1) / 2
      @$el.append view.render().el

  render: ->
    @$el.html @template(tasks: @collection.toJSON())
    @addAll()
    @
