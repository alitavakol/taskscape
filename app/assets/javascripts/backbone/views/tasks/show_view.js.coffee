Taskscape.Views.Tasks ||= {}

class Taskscape.Views.Tasks.ShowView extends Backbone.View
  template: JST["backbone/templates/tasks/show"] # skeleton template

  details_template: JST["backbone/templates/tasks/details"]
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

    @avatars = new Taskscape.Views.Tasks.Assignments.IndexView
      collection: @model.get('assignments')
    @avatars.task = @

    # bind view to model, so if model changes, it will be reflected into view
    @listenTo @model, 'destroy', -> @remove()
    @listenTo @model, 'change:title', (model, response, options) -> @render_title()
    @listenTo @model, 'change:effort', (model, response, options) -> @render_effort()
    @listenTo @model, 'change:status', (model, response, options) -> @render_status()
    @listenTo @model, 'change:importance change:urgency', (model, response, options) -> @render_importance_and_urgency()
    @listenTo @model, 'change:color', (model, response, options) -> 
      @update_plate()
      @render_title()

    @

  # this function renders task's skeleton and calls render_* to render attributes
  render: ->
    # render skeleton
    @$el.html @template @model.toJSON()

    @update_plate()
    @render_effort(true) # render effort of the task (change shape size)
    @render_status() # render status of the task
    @render_importance_and_urgency() # render importance and urgency of the task
    @render_avatars() # attach avatar of assignees to task's shape

    # register some nodes so we can find this view from them
    @$('circle.draggable,.tappable,.task-container').data('view_object', @)
    @$el.data('view_object', @)

    @focus false
    @

  update_plate: ->
    color = tinycolor(@model.get('color'))
    @$('.plate').attr
      fill: color.lighten().toHexString()
      stroke: color.darken().toHexString()
    @

  # this function renders avatar of assignees attached to task's shape
  render_avatars: ->
    @$('.avatar-container').html @avatars.render().el
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

    return if immediately # skip animation

    # change task size with animation
    delta = (@R - R0) / 5 # animation delta
    $(t: 1).animate t: 5, 
      step: (t) => 
        R = R0 + delta * t
        @$('.task-container').attr
          transform: "scale(#{R / 72})"
          "stroke-width": 180 / R

      complete: =>
        SVG.ensure_visible(@$el, @x, @y) if window.focused_view == @

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
      SVG.init_viewbox @$el # initialize svg viewbox
      SVG.autofit @$el # autofit content

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
    @bring_to_front()
    @$el.fadeTo 100, .85
    false

  # called while task's shape is dragging
  on_drag: (dx, dy) =>
    @move
      x: @x + dx
      y: @y + dy
    false

  # called when dragging of task's shape is finished
  on_drag_end: ->
    @$el.fadeTo 100, 1
    SVG.ensure_visible(@$el, @x, @y) if window.focused_view == @
    false # do not remove this!

  # moves task's shape on screen
  # if x new position is not given, moves it to last stable position @x0, @y0
  move: (options) ->
    options ||= {}

    # use last stable position if new position is not provided in the arguments
    options.x = @x0 unless options.x
    options.y = @y0 unless options.y

    if options.animation
      # current position
      x = @x
      y = @y

      # animation delta
      delta_x = (options.x - x) / 5
      delta_y = (options.y - y) / 5

      # animate to new position
      $(t: 1).animate t: 5, 
        step: (t) => @move 
          x: x + delta_x * t
          y: y + delta_y * t

    else # move without animation
      @$el.attr transform: "translate(#{options.x} #{options.y})"

    # new position
    @x = options.x
    @y = options.y

    @save_position() if options.save
    @

  stable_position: ->
    @x0 = @x
    @y0 = @y
    @

  save_position: ->
    return unless @model.id
    @model.save
      x: @x
      y: @y
    ,
      pick: ['x', 'y', 'effort'] # save effort too, because changing it may result in change of position if the task with new size, was overlapping other objects

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
        @$('.shadow').fadeTo 100, 1
        @$('.focus-border').attr opacity: .5

        @bring_to_front()

        # show task details side bar
        @details.$el.show()

      changed = SVG.ensure_visible(@$el, @x, @y)
      SVG.zoom_to(@$el, @x, @y) if old_focused_view == @ && !changed

    else
      # update view
      @$('.shadow').fadeTo 100, .3
      @$('.focus-border').attr opacity: 0

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

  handle_drag_enter: (dropped_object) ->
    if dropped_object.relatedTarget && dropped_object.relatedTarget.id == 'drop-task' # a #drop-task element dropped into canvas
      $('#drop-task.dragging .drop-emblem').hide()
      $('#drop-task.dragging .prohibited-emblem').show()

    else unless dropped_object instanceof Taskscape.Views.Projects.ShowView or dropped_object.target
      @$('.standout').fadeIn(100).attr
        "stroke-width": window.SVG.drag_scale * 76 / @R # make stroke width independent of zoom level and shape size

  handle_drag_leave: (dropped_object) ->
    unless dropped_object instanceof Taskscape.Views.Projects.ShowView or dropped_object.target
      @$('.standout').fadeOut(100)

  # handle drop of objects (project members, other tasks, ...) into this task
  handle_drop: (dropped_object) ->
    # if dropped object is a project member, assign them to undertake this task
    if dropped_object instanceof Taskscape.Views.Projects.Members.MemberView
      @add_assignment dropped_object.model

    # if dropped object is avatar of an assignee (who was attached to another task), 
    # then un-assign them from previous task, and assign them to undertake this task
    else if dropped_object instanceof Taskscape.Views.Tasks.Assignments.AvatarView
      @update_assignment dropped_object.model

    @

  handle_drop_enter: (dropzone) ->
    @

  handle_drop_leave: (dropzone) ->
    @

  # assign this task to the specified user
  add_assignment: (user) ->
    assignment = new Taskscape.Models.Assignment
      task_id: @model.id
      assignee_id: user.get('member_id')
      name: user.get('name')
      avatar: user.get('avatar')

    @model.get('assignments').add assignment

    assignment.save {},
      wait: true # wait for the server before adding the new model to the collection
      error: (model, response, options) =>
        @model.get('assignments').remove model # remove assignment

    @

  # update specified assignment: remove the assignee from another task, and add it to this task
  update_assignment: (assignment) ->
    # return if avatar is dropped into its own task
    return if @model.id == assignment.get('task_id').id

    assignment.save task_id: @model.id,
      pick: ['task_id']
      previous_value: assignment.get('task_id')
      error: (model, response, options) ->
        assignment.set task_id: options.previous_value
    @
