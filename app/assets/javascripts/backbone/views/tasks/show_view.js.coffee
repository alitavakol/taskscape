Taskscape.Views.Tasks ||= {}

class Taskscape.Views.Tasks.ShowView extends Backbone.View
  template: JST["backbone/templates/tasks/show"]

  initialize: ->
    # radius of the shape
    effort = @model.get('effort')
    if effort == 'small_effort'
      @R = 72
    else if effort == 'medium_effort'
      @R = 104
    else if effort == 'large_effort'
      @R = 136
    else if effort == 'very_large_effort'
      @R = 198

    @x = @model.get('x')
    @y = @model.get('y')

  render: ->
    @$el.html @template _.extend @model.toJSON(), R: @R

    @$('.draggable,.tappable').data('view_object', @)
    @focus false

    return @

  on_drag_start: ->
    @$el.attr opacity: .85

    @x0 = @x
    @y0 = @y

    false

  on_drag: (dx, dy) ->
    @move dx, dy
    false

  on_drag_end: (e) ->
    @$el.attr opacity: 1

    @model.save
      x: @x
      y: @y
    ,
      pick: ['x', 'y'] # save group_id, for the case that the shape is fininshed dropping

    false # do not remove this!

  move: (dx, dy) ->
    @x += dx
    @y += dy
    @$el.attr transform: "translate(#{@x} #{@y})"

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
