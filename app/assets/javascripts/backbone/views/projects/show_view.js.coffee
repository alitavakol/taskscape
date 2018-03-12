Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.ShowView extends Backbone.View
  template: JST["backbone/templates/projects/show"]
  new_task_dialog_template: JST["backbone/templates/projects/dialogs/new_task"]

  events:
    "wheel svg"           : "on_mousewheel"
    "click"               : "on_click"

  initialize: ->
    @objects = []
    x = y = 0

    @listenTo @model.get('tasks'), 'add', (model, response, options) -> 
      @add_task(model)
      @remove_overlaps()

    @listenTo @model.get('tasks'), 'remove', (model, response, options) ->
      # remove view of removed task
      @objects = @objects.filter (o) -> o.model.id != model.id

      # restore other tasks to their original position (their position may have been changed to remove overlaps)
      @objects.forEach (o) -> 
        o.move animation: true

  render: ->
    @$el.html(@template(@model.toJSON()))

    @$('.tappable').data('view_object', @)
    @svg = @$('svg#canvas')

    # render members side bar
    members_view = new Taskscape.Views.Projects.Members.IndexView(collection: @model.get('memberships'))
    @$("#project-members-sidebar").append members_view.render().el

    # render tasks of this project (supertask)
    @model.get('tasks').forEach (t) => @add_task t

    @enable_drag() # enable dragging tasks
    @enable_drop() # enable dropping an object into another
    @enable_pan() # enable panning the canvas svg
    @enable_tap() # enable focus object on tap or click

    # update svg viewbox on resize
    $(window).off('resize').on 'resize', =>
      @svg.data('padding-left', 1.2 * @$('#project-members-sidebar').width())
      @svg.data('padding-right', if window.focused_view == @ then 0 else @$('#task-details-sidebar').width())
      SVG.update_viewbox_variables @svg
      SVG.ensure_visible(window.focused_view.$el, window.focused_view.x, window.focused_view.y) if window.focused_view != @

    return this

  add_task: (t) ->
    view = new Taskscape.Views.Tasks.ShowView
      model: t
      attributes: 
        transform: "translate(#{t.get('x')} #{t.get('y')})"

    @svg.append(view.render().el)
    @$('#task-details-sidebar').append(view.details.render().el)

    @objects.push view
    @stopListening t
    @listenTo t, 'change:effort', (model, response, options) -> @remove_overlaps() # ensure no overlap if task size changes (as a consequence of changing effort)

  bring_to_front: ->
    # do nothing

  # reflect focus state in view
  focus: (focused) ->
    if focused
      old_focused_view = window.focused_view ? null
      return if old_focused_view && SVG.autofit @svg

      if old_focused_view != @
        old_focused_view.focus(false, true) if window.focused_view # remove focus from previously focused object
        window.focused_view = @

        @svg.data('padding-right', 0)
        @$('#task-details-sidebar').fadeOut
          duration: 100
          complete: -> 
            old_focused_view.details.$el.hide() if old_focused_view # hide task details side bar

        SVG.autofit @svg

    else
      @svg.data('padding-right', @$('#task-details-sidebar').width())
      @$('#task-details-sidebar').fadeIn 100

  # this function re-arranges objects (shapes) so to ensure they do not overlap any other
  # returns true if arrangements changed
  remove_overlaps: ->
    moved_objects = [] # moved objects after re-arrangement
    new_object_added = false

    @objects.forEach (o) -> o.stable_position()

    # compute new positions to have no overlaps
    loop
      moved = false
      for m in @objects
        new_object_added = true unless m.model.id

        if @draw_away_slightly(m)
          moved = true
          moved_objects.push(m)

      # repeat again unless no change made in this round
      break unless moved # finish the process if no change happened in this round

    _.uniq(moved_objects).forEach (m) -> 
      x = m.x
      y = m.y

      # restore original position of objects, then move them to their new position by animation
      m.move().move x: x, y: y, animation: true, save: !new_object_added

    return moved_objects.length > 0

  # moves the specified object (shape) a little amount if it overlaps some other objects
  # returns true if position changed
  draw_away_slightly: (a) ->
    # movement vector
    vx = 0
    vy = 0

    # calculate direction and size of the movement vector
    for b in @objects
      continue if a == b

      dx = a.x - b.x
      dy = a.y - b.y
      d = Math.sqrt(dx*dx + dy*dy)

      if d < 1.25 * (a.R + b.R)
        if d < 1
          dx = .1
          dy = .1
          d = 1
        # add a little amount to movement vector which is directly proportional ratio of object sizes b.R/a.R
        vx += 100/a.R * 20*dx/d
        vy += 100/a.R * 20*dy/d

    if vx || vy
      a.move
        x: a.x + vx
        y: a.y + vy
      return true

    return false

  # handle zoom-in/zoom-out on mouse wheel
  on_mousewheel: (e) ->
    # inactivate zoom if popover dialog is visible
    return if $('.popover') && $('.popover').css('display')
    SVG.zoom @svg, e

  post_render: ->
    # initialize svg viewbox
    @svg.data('padding-left', 1.2 * @$('#project-members-sidebar').width())
    SVG.init_viewbox @svg

    # call post_render on all included views
    @objects.forEach (view) ->
      view.post_render()

    # resolve object overlaps
    @remove_overlaps()

    # autofit content
    SVG.autofit @svg, true

    @focus true

  # enable panning the canvas svg
  enable_pan: ->
    interact('.pannable').draggable
      max: 1
      inertia: true

      onstart: (e) ->
        $('#popover').popover('hide')

      # call this function on every dragmove e
      onmove: (e) =>
        SVG.move @svg, e.dx, e.dy

      # call this function on every dragend e
      onend: (e) ->

  # enable focus object on tap or click
  enable_tap: ->
    interact('.tappable').on 'tap', (e) =>
      if e.target.classList.contains('shadow')
        @focus true # treat shadow image as if it is not part of clicked object

      else
        $(e.currentTarget).data('view_object').focus true
        window.focused_view.$el.appendTo window.focused_view.$el.parent()

      $('#popover').popover('hide')
      e.stopPropagation()

  # enable dragging tasks
  enable_drag: ->
    interact('.draggable').draggable
      max: 1
      inertia: false

      onstart: (e) ->
        $('#popover').popover('hide')
        window.dragging_view = $(e.currentTarget).data('view_object')
        window.dragging_view.on_drag_start()

      # call this function on every dragmove e
      onmove: (e) ->
        window.dragging_view.on_drag(e.dx * window.SVG.drag_scale, e.dy * window.SVG.drag_scale)

      # call this function on every dragend e
      onend: (e) =>
        # call object to save its new position only if remove_overlaps did not call it
        window.dragging_view.on_drag_end()
        if window.dragging_view.save_position
          window.dragging_view.save_position() unless @remove_overlaps()

  # enable dropping something into objects
  enable_drop: ->
    interact('.dropzone').dropzone
      # overlap: 'center' && 'pointer',
      ondropactivate: (e) ->

      ondragenter: (e) ->
        dropped_object = $(e.relatedTarget).data('view_object')
        dropzone = $(e.target).data('view_object')
        dropzone.handle_drag_enter dropped_object ? e
        window.hot_dropzone = dropzone

      ondragleave: (e) ->
        dropped_object = $(e.relatedTarget).data('view_object')
        dropzone = $(e.target).data('view_object')
        dropzone.handle_drag_leave dropped_object ? e
        window.hot_dropzone = null

      ondrop: (e) ->
        dropped_object = $(e.relatedTarget).data('view_object')
        dropzone = $(e.target).data('view_object')
        dropzone.handle_drag_leave dropped_object ? e
        dropzone.handle_drop dropped_object ? e
        @

      ondropdeactivate: (e) ->

  handle_drag_enter: (e) ->
    if e.relatedTarget && e.relatedTarget.id == 'drop-task' # a #drop-task element dropped into canvas
      $('#drop-task.dragging .drop-emblem').show()
      $('#drop-task.dragging .prohibited-emblem').hide()
    @

  handle_drag_leave: (e) ->
    if e.relatedTarget && e.relatedTarget.id == 'drop-task' # a #drop-task element dropped into canvas
      $('#drop-task.dragging .drop-emblem').hide()
    @

  handle_drop: (e) ->
    if e.relatedTarget && e.relatedTarget.id == 'drop-task' # a #drop-task element dropped into canvas
      # create a new task
      task = new Taskscape.Models.Task
        x: e.dragEvent.clientX * window.SVG.drag_scale + window.SVG.vbx
        y: e.dragEvent.clientY * window.SVG.drag_scale + window.SVG.vby

      # add to collection
      @model.get('tasks').add task

      @show_task_dialog_for task, 
        x: e.dragEvent.clientX # + (if e.dragEvent.clientX > e.target.clientWidth / 2 then -50 else 50)
        y: e.dragEvent.clientY + (if e.dragEvent.clientY > e.target.clientHeight / 2 then -20 else 20)

    @

  on_click: (e) ->
    # hide any open popover dialog if clicked an element that is not a child of the popover dialog element
    $('#popover').popover('hide') unless $(e.target).closest('.popover').length

  # present a dialog to user to enter title and color of the new task
  show_task_dialog_for: (task, options) ->
    $('#popover').popover
      title: 'Create a new task'
      content: @new_task_dialog_template(task.toJSON())
      html: true
      placement: 'auto'
      trigger: 'focus'

    .css # place the dialog on drop location
      top: options.y
      left: options.x

    .popover('show')

    # .on 'shown.bs.popover', -> console.log 'shown.bs.popover'

    .on 'hidden.bs.popover', => # triggered when dialog disappeared
      $('#popover').popover('dispose')

      unless task.id # popover dialog was cancelled and so task did not save
        task.destroy() # destroy the new task

    .on 'save.bs.popover', => # triggered when save button of the dialog is pushed
      # save task with provided title and color
      task.save {}, 
        pick: ['title', 'x', 'y', 'color', 'supertask_id']
        # success: =>
        #   @objects.forEach (o) -> o.stable_position()
        error: (model, response, options) ->
          model.destroy() # remove task if sync failed

      # close the popover dialog
      $('#popover').popover('dispose')

    $('#new-task-title').focus()

    # respond to color pick
    $('#color-tool div').click (e) ->
      $('#color-tool div').removeClass('fa fa-check')
      $(e.target).addClass('fa fa-check')
      task.set color: "##{e.target.id.substr(6)}"

    # respond to title change
    $('#new-task-title').on 'keyup', (e) ->
      task.set title: e.target.value
      $('.popover .btn-success').prop('disabled', e.target.value.length == 0)
      if e.keyCode == 13 && e.target.value.length > 0
        $('#popover').trigger('save.bs.popover')
        return
  @
