Taskscape.Views.Tasks ||= {}
Taskscape.Views.Tasks.Assignments ||= {}

class Taskscape.Views.Tasks.Assignments.AvatarView extends Backbone.View
  template: JST["backbone/templates/tasks/assignments/avatar"]

  tagName: "g"
  className: 'draggable'

  initialize: ->
    @listenTo @model, 'change', (model, response, options) -> @render()
    @listenTo @model, 'destroy', -> @remove()

  render: ->
    @$el.html @template _.extend @model.toJSON(), rotation_coefficient: @rotation_coefficient
    @$el.data('view_object', @)
    @

  # called when dragging of task's shape is just started
  on_drag_start: ->
    @task.bring_to_front()
    @x = @y = 0
    false

  # called while task's shape is dragging
  on_drag: (dx, dy) =>
    @x += dx
    @y += dy
    @$el.attr transform: "translate(#{@x * 72 / @task.R} #{@y * 72 / @task.R})"
    false

  # called when dragging of task's shape is finished
  on_drag_end: ->
    @$el.removeAttr 'transform'

    if !window.hot_dropzone || window.hot_dropzone instanceof Taskscape.Views.Projects.ShowView
      # avatar is dropped into nowhere; so, delete it
      @model.destroy 
        backup: _.extend @model.toJSON(), task_id: @task.model.id
        collection: @model.collection
        error: (model, response, options) ->
          options.collection.add new Taskscape.Models.Assignment options.backup # restore the assignment

    false # do not remove this!
