Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.ShowView extends Backbone.View
  template: JST["backbone/templates/projects/show"]

  events:
    "wheel svg" : "on_mousewheel"

  initialize: ->
    @objects = []

  render: ->
    @$el.html(@template(@model.toJSON()))

    @$('.tappable').data('view_object', @)
    @svg = @$('svg')[0]

    # render tasks of this project (supertask)
    @model.get('tasks').forEach (t) =>
      view = new Taskscape.Views.Tasks.ShowView
        model: t
        attributes: 
          transform: "translate(#{t.get('x')} #{t.get('y')})"

      @$('svg').append(view.render().el)
      # @$el.append(view.details.render().el)

      @objects.push view
      @listenTo t, 'change:effort', (model, response, options) -> @remove_overlaps() # ensure no overlap if task size changes (as a consequence of changing effort)

    @enable_drag() # enable dragging tasks
    @enable_pan() # enable panning the canvas svg
    @enable_tap() # enable focus object on tap or click

    # update svg viewbox on resize
    $(window).resize =>
      SVG.update_viewbox @svg, true

    return this

  # reflect focus state in view
  focus: (focused) ->
    if focused
      if window.focused_view != @
        window.focused_view.focus false if window.focused_view # remove focus from previously focused object
        window.focused_view = @

      SVG.autofit @svg

  # this function re-arranges objects (shapes) so to ensure they do not overlap any other
  # returns true if arrangements changed
  remove_overlaps: ->
    moved_objects = [] # moved objects after re-arrangement

    loop
      moved = false
      for m in @objects
        if @draw_away_slightly(m)
          moved = true
          moved_objects.push(m)
      break unless moved

    # save new position of moved objects
    _.uniq(moved_objects).forEach (o) ->
      o.on_drag_end()

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
      a.move(vx, vy)
      return true

    return false

  # handle zoom-in/zoom-out on mouse wheel
  on_mousewheel: (e) ->
    SVG.zoom @svg, e

  post_render: ->
    # initialize svg viewbox
    SVG.init_viewbox @svg

    # call post_render on all included views
    @objects.forEach (view) ->
      view.post_render()

    # resolve object overlaps
    @remove_overlaps()

    # autofit content
    SVG.autofit @svg

  # enable panning the canvas svg
  enable_pan: ->
    interact('.pannable').draggable
      # allow dragging of multple elements at the same time
      max: Infinity
      inertia: true

      onstart: (e) =>
        SVG.update_viewbox @svg, true

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
      # allow dragging of multple elements at the same time
      max: Infinity
      inertia: true

      onstart: (e) =>
        window.dragging_view = $(e.currentTarget).data('view_object')
        window.dragging_view.focus true
        window.dragging_view.on_drag_start()

        SVG.update_viewbox @svg, true

      # call this function on every dragmove e
      onmove: (e) ->
        window.dragging_view.on_drag(e.dx * window.drag_scale, e.dy * window.drag_scale)

      # call this function on every dragend e
      onend: (e) =>
        # call object to save its new position only if remove_overlaps did not call it
        window.dragging_view.on_drag_end() unless @remove_overlaps()
