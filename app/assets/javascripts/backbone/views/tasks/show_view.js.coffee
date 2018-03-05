Taskscape.Views.Tasks ||= {}

class Taskscape.Views.Tasks.ShowView extends Backbone.View
  template: JST["backbone/templates/tasks/show"] # skeleton template

  details_template: JST["backbone/templates/tasks/details"]
  avatars_template: JST["backbone/templates/tasks/avatars"]
  status_template: JST["backbone/templates/tasks/status"]
  title_template: JST["backbone/templates/tasks/title"]
  importance_and_urgency_template: JST["backbone/templates/tasks/importance_and_urgency"]

  tagName: 'g'

  initialize: ->
    @x = @model.get('x')
    @y = @model.get('y')

    @details = new Taskscape.Views.Tasks.DetailsView
      model: @model
      className: 'task-details'

    # bind view to model, so if model changes, it will be reflected into view
    @listenTo @model, 'change:title', (model, response, options) -> @render_title()
    @listenTo @model, 'change:effort', (model, response, options) -> @render_effort()
    @listenTo @model, 'change:status', (model, response, options) -> @render_status()
    @listenTo @model, 'change:importance change:urgency', (model, response, options) -> @render_importance_and_urgency()
    @listenTo @model, 'change:assignees', (model, response, options) -> @render_avatars()

    @

  # this function renders task's skeleton and calls render_* to render attributes
  render: ->
    # render skeleton
    @$el.html @template @model.toJSON()

    @render_effort(true) # render effort of the task (change shape size)
    @render_status() # render status of the task
    @render_importance_and_urgency() # render importance and urgency of the task
    @render_avatars() # attach avatar of assignees to task's shape

    # register some nodes so we can find this view from them
    @$('.draggable,.tappable,.task-container').data('view_object', @)
    @$el.data('view_object', @)

    @focus false
    @

  # this function renders avatar of assignees attached to task's shape
  render_avatars: ->
    @$('.avatar-container').html @avatars_template(@model.toJSON())
    @

  # this function renders importance and urgency indicators
  render_importance_and_urgency: ->
    @$('.importance_and_urgency').html @importance_and_urgency_template(@model.toJSON())
    @

  # this function renders status indicator
  render_status: ->
    @$('.status').html @status_template(@model.toJSON())
    @

  # this function scales task's skeleton shape to reflect effort attribute
  render_effort: (immediately) ->
    R0 = @R
    @update_shape_size()
    R0 ?= @R

    # render immediately, if we are rendering for the first time, without animation
    if immediately
      @$('.task-container').attr
        transform: "scale(#{@R / 72})"
        "stroke-width": 180 / @R

    # re-draw title when task's shape size changes
    @render_title()

    return if immediately

    # compute animation delta
    delta = (@R - R0) / 5

    # animate
    $(t: 1).animate t: 5, 
      step: (t) => 
        R = R0 + delta * t
        @$('.task-container').attr
          transform: "scale(#{R / 72})"
          "stroke-width": 180 / R
        @

      complete: =>
        SVG.ensure_visible @ if window.focused_view == @
        @

    @

  # this function renders title of the task
  render_title: ->
    @$('.title-container').html @title_template(@model.toJSON())
    @autofit_title()
    @

  # performs necessary steps that require elements to be rendered by browser,
  # and size of elements are calculated
  post_render: ->
    if @tagName == 'svg'
      SVG.init_viewbox @el # initialize svg viewbox
      SVG.autofit @el # autofit content

    @autofit_title()

  # computes reference size of the shape according to its effort
  update_shape_size: ->
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
    @

  # called when dragging of task's shape is just started
  on_drag_start: ->
    @$el.attr opacity: .85

    @x0 = @x
    @y0 = @y

    false

  # called while task's shape is dragging
  on_drag: (dx, dy) ->
    @move(@x + dx, @y + dy)
    false

  # called when dragging of task's shape is finished
  on_drag_end: (e) ->
    @$el.attr opacity: 1

    @model.save
      x: @x
      y: @y
    ,
      pick: ['x', 'y', 'effort'] # save effort too, because changing it may result in change of position if the task with new size, was overlapping other objects

    SVG.ensure_visible @ if window.focused_view == @

    false # do not remove this!

  # moves task's shape on screen
  move: (x, y) ->
    @x = x
    @y = y
    @$el.attr transform: "translate(#{@x} #{@y})"

  bring_to_front: ->
    # show this object on top of other objects
    @$el.appendTo @$el.parent()

  # this function reflects set/kill focus into view
  focus: (focused, keep) ->
    if focused
      old_focused_view = window.focused_view ? null

      if old_focused_view != @
        window.focused_view = @

        # remove focus from previously focused object
        old_focused_view.focus false if old_focused_view

        # update view
        @$('.shadow').attr opacity: 1
        @$('.plate').attr
          stroke: tinycolor(@model.get('color')).darken().darken().darken().toHexString()

        @bring_to_front()

        # show task details side bar
        @details.$el.show()

      changed = SVG.ensure_visible @
      SVG.zoom_to(this) if old_focused_view == @ && !changed

    else
      # update view
      @$('.shadow').attr opacity: .3
      @$('.plate').attr
        stroke: tinycolor(@model.get('color')).darken().toHexString()

      # hide task details side bar
      @details.$el.hide() unless keep

    @

  # this function tries to decrease title font size and ellipsize it
  # until it fits into bounding box defined by .title-container
  autofit_title: ->
    m = parseInt @$('.title-container').parent().attr('height')

    title = @$('.title')
    font_size = parseInt title.css('font-size')
    min_font_size = 1520 / @R

    # decrease font-size until it fits
    while title.height() > m && --font_size > min_font_size
      title.css 'font-size', "#{font_size}px"

    # trim and ellipsize text until it fits
    while title.height() > m
      str = title.html() unless str
      str = str.substring(0, str.lastIndexOf(' ')) + '…'
      break unless str.length > 1
      title.html(str)

    true
