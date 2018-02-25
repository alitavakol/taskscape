Taskscape.Views.Tasks ||= {}

class Taskscape.Views.Tasks.ShowView extends Backbone.View
  template: JST["backbone/templates/tasks/show"]

  render: ->
    @$el.html(@template(@model.toJSON()))

    @x = @model.get('x')
    @y = @model.get('y')

    @$el.attr transform: "translate(#{@x} #{@y})"
    @$('.draggable').data('view_object', @)

    @

  on_drag_start: ->
    @$el.attr opacity: .75

    @x0 = @x
    @y0 = @y

    false

  on_drag: (dx, dy) ->
    @x += dx
    @y += dy
    @$el.attr transform: "translate(#{@x} #{@y})"

    false

  on_drag_end: (e) ->
    @$el.attr opacity: 1

    @model.save
      x: @x
      y: @y
    ,
      pick: ['x', 'y'] # save group_id, for the case that the shape is fininshed dropping

    false # do not remove this!
