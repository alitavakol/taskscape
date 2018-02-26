Taskscape.Views.Tasks ||= {}

class Taskscape.Views.Tasks.ShowView extends Backbone.View
  template: JST["backbone/templates/tasks/show"]

  render: ->
    @$el.html(@template(@model.toJSON()))

    @$('.draggable,.tappable').data('view_object', @)
    @focus false

    @x = @model.get('x')
    @y = @model.get('y')

    @

  on_drag_start: ->
    @$el.attr opacity: .85

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

  focus: (focused) ->
    if focused
      if window.focused_view != @
        window.focused_view.focus false if window.focused_view
        @$('.shadow').attr opacity: 1
        @$('.plate').attr
          stroke: tinycolor(@model.get('color')).darken().darken().darken().toHexString()
        window.focused_view = @

    else
      @$('.shadow').attr opacity: .3
      @$('.plate').attr
        stroke: tinycolor(@model.get('color')).darken().toHexString()
