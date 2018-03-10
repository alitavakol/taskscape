Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.ShowView extends Backbone.View
  template: JST["backbone/templates/projects/show"]

  events:
    "wheel svg" : "on_mousewheel"

  initialize: ->
    @objects = []
    x = y = 0

  render: ->
    @$el.html(@template(@model.toJSON()))

    @$('.tappable').data('view_object', @)
    @svg = @$('svg#canvas')

    # render members side bar
    members_view = new Taskscape.Views.Projects.Members.IndexView(collection: @model.get('memberships'))
    @$("#project-members-sidebar").append members_view.render().el

    # render tasks of this project (supertask)
    @model.get('tasks').forEach (t) =>
      view = new Taskscape.Views.Tasks.ShowView
        model: t
        attributes: 
          transform: "translate(#{t.get('x')} #{t.get('y')})"

      @svg.append(view.render().el)
      @$('#task-details-sidebar').append(view.details.render().el)

      @objects.push view
      @stopListening t
      @listenTo t, 'change:effort', (model, response, options) -> @remove_overlaps() # ensure no overlap if task size changes (as a consequence of changing effort)

      view.model.set
        x: @x - 1
      view.model.trigger('change:x')

    @enable_drag() # enable dragging tasks
    @enable_drop() # enable dropping an object into another
    @enable_pan() # enable panning the canvas svg
    @enable_tap() # enable focus object on tap or click

    # update svg viewbox on resize
    $(window).resize =>
      @svg.data('padding-left', 1.2 * @$('#project-members-sidebar').width())
      @svg.data('padding-right', if window.focused_view == @ then 0 else @$('#task-details-sidebar').width())
      SVG.update_viewbox_variables @svg
      SVG.ensure_visible(window.focused_view.$el, window.focused_view.x, window.focused_view.y) if window.focused_view != @

    return this

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

    # make a backup of initial position of objects
    @objects.forEach (m) ->
      m.x0 = m.x
      m.y0 = m.y

    # compute new positions to have no overlaps
    loop
      moved = false
      for m in @objects
        if @draw_away_slightly(m)
          moved = true
          moved_objects.push(m)
      break unless moved

    # compute animation delta for each object
    @objects.forEach (m) ->
      m.delta_x = (m.x - m.x0) / 5
      m.delta_y = (m.y - m.y0) / 5
      m.move(m.x0, m.y0) # restore original position

    # animate objects to their new position
    $(t: 1).animate t: 5, 
      step: (t) => 
        for m in @objects
          m.move(m.x0 + m.delta_x * t, m.y0 + m.delta_y * t)
        @

      complete: ->
        # save new position of moved objects
        _.uniq(moved_objects).forEach (o) -> o.on_drag_end()
        @

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
      a.move(a.x + vx, a.y + vy)
      return true

    return false

  # handle zoom-in/zoom-out on mouse wheel
  on_mousewheel: (e) ->
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

      e.stopPropagation()

  # enable dragging tasks
  enable_drag: ->
    interact('.draggable').draggable
      max: 1
      inertia: false

      onstart: (e) ->
        window.dragging_view = $(e.currentTarget).data('view_object')
        window.dragging_view.on_drag_start()

      # call this function on every dragmove e
      onmove: (e) ->
        window.dragging_view.on_drag(e.dx * window.drag_scale, e.dy * window.drag_scale)

      # call this function on every dragend e
      onend: (e) =>
        # call object to save its new position only if remove_overlaps did not call it
        window.dragging_view.on_drag_end() unless @remove_overlaps()

  # enable dropping something into objects
  enable_drop: ->
    interact('.dropzone').dropzone
      # overlap: 'center' && 'pointer',
      ondropactivate: (e) ->

      ondragenter: (e) ->
        dropped_object = $(e.relatedTarget).data('view_object')
        dropzone = $(e.target).data('view_object')
        dropzone.handle_drag_enter dropped_object ? e
        window.hot_dropzone = dropped_object

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
    @

  handle_drag_leave: (e) ->
    @

  handle_drop: (e) ->
    console.log e
    @
