Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.ShowView extends Taskscape.Views.Projects.ProjectView
  template: JST["backbone/templates/projects/show"]

  events:
    "wheel svg"       : "on_mousewheel"
    "click .btn-edit" : "edit_project"

  render: ->
    super

    # render members side bar
    members_view = new Taskscape.Views.Projects.Members.IndexView(model: @model)
    @$("#project-members-sidebar").append members_view.render().el

    @enable_drag() # enable dragging tasks
    @enable_drop() # enable dropping an object into another
    @enable_pan() # enable panning the canvas svg
    @enable_tap() # enable focus object on tap or click

    # update svg viewbox on resize
    $(window).off('resize').on 'resize', =>
      @svg.data('padding-left', 1.2 * @$('#project-members-sidebar').width())
      @svg.data('padding-right', if window.focused_view == @ then 0 else @$('#task-details-sidebar').width())
      SVG.update_viewbox_variables @svg
      SVG.ensure_visible(window.focused_view.$el, window.focused_view.x, window.focused_view.y) if window.focused_view && window.focused_view != @

    @

  add_task: (t) ->
    view = super
    @$('#task-details-sidebar').append(view.details.render().el)

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
            old_focused_view && old_focused_view.details && old_focused_view.details.$el.hide() # hide task details side bar

        SVG.autofit @svg

    else
      @svg.data('padding-right', @$('#task-details-sidebar').width())
      @$('#task-details-sidebar').fadeIn 100

  # handle zoom-in/zoom-out on mouse wheel
  on_mousewheel: (e) ->
    # inactivate zoom if popover dialog is visible
    return if $('.popover') && $('.popover').css('display')
    SVG.zoom @svg, e

  post_render: ->
    @svg.data('padding-left', 1.2 * @$('#project-members-sidebar').width()) # set svg padding counting fot members sidebar
    super
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
    interact('.tappable').off('tap').on 'tap', (e) =>
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
        window.dragging_view.on_drag_end()
        if window.dragging_view instanceof Taskscape.Views.Tasks.ShowView
          @remove_overlaps cause: window.dragging_view

  # enable dropping something into objects
  enable_drop: ->
    interact('.dropzone').dropzone
      # overlap: 'center' && 'pointer',
      ondropactivate: (e) ->

      ondragenter: (e) ->
        dropped_object = $(e.relatedTarget).data('view_object')
        dropzone = $(e.target).data('view_object')
        dropzone.handle_drag_enter(dropped_object ? e) if dropzone
        window.hot_dropzone = dropzone

      ondragleave: (e) ->
        dropped_object = $(e.relatedTarget).data('view_object')
        dropzone = $(e.target).data('view_object')
        dropzone.handle_drag_leave(dropped_object ? e) if dropzone
        window.hot_dropzone = null

      ondrop: (e) ->
        dropped_object = $(e.relatedTarget).data('view_object')
        dropzone = $(e.target).data('view_object')
        if dropzone
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

      @edit_task_view ||= new Taskscape.Views.Tasks.EditView()
      @edit_task_view.render task, 
        x: e.dragEvent.clientX # + (if e.dragEvent.clientX > e.target.clientWidth / 2 then -50 else 50)
        y: e.dragEvent.clientY + (if e.dragEvent.clientY > e.target.clientHeight / 2 then -20 else 20)
        error: (model) -> model.destroy() # remove task if sync failed
        cancel: -> task.destroy() unless task.id # if task.id is null, popover dialog was cancelled, so destroy the task

    @
