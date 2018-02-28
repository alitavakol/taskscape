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
        tagName: 'g'
        attributes: 
          transform: "translate(#{t.get('x')} #{t.get('y')})"
      @$('svg').append(view.render().el)
      @objects.push view

    # enable dragging tasks
    interact('.draggable').draggable
      # allow dragging of multple elements at the same time
      max: Infinity
      inertia: true

      onstart: (e) =>
        window.dragging_view = $(e.currentTarget).data('view_object')
        window.dragging_view.focus true
        window.dragging_view.on_drag_start()

        @update_viewbox true

      # call this function on every dragmove e
      onmove: (e) ->
        window.dragging_view.on_drag(e.dx * window.drag_scale, e.dy * window.drag_scale)

      # call this function on every dragend e
      onend: (e) =>
        # call object to save its new position only if remove_overlaps did not call it
        window.dragging_view.on_drag_end() unless @remove_overlaps()

    # enable panning the canvas svg
    interact('.pannable').draggable
      # allow dragging of multple elements at the same time
      max: Infinity
      inertia: true

      onstart: (e) =>
        @update_viewbox true

      # call this function on every dragmove e
      onmove: (e) =>
        @vbx -= e.dx * window.drag_scale
        @vby -= e.dy * window.drag_scale
        @svg.setAttribute('viewBox', "#{@vbx} #{@vby} #{@vbw} #{@vbh}")

      # call this function on every dragend e
      onend: (e) ->

    # focus tapped object
    interact('.tappable').on 'tap', (e) =>
      if e.target.classList.contains('shadow')
        @focus true # treat shadow image as if it is not part of clicked object

      else
        $(e.currentTarget).data('view_object').focus true
        window.focused_view.$el.appendTo window.focused_view.$el.parent()

      e.stopPropagation()

    # update svg viewbox on resize
    $(window).resize =>
      @update_viewbox true

    return this

  # reflect focus state in view
  focus: (focused) ->
    if focused
      if window.focused_view != @
        window.focused_view.focus false if window.focused_view # remove focus from previously focused object
        window.focused_view = @
      @autofit()

  # this function re-arranges objects (shapes) so to ensure they do not overlap any other
  # returns true if arrangements changed
  remove_overlaps: ->
    moved_objects = [] # moved objects after re-arrangement

    loop
      moved = false
      for m in @objects
        if @move_a_bit(m)
          moved = true
          moved_objects.push(m)
      break unless moved

    # save new position of moved objects
    _.uniq(moved_objects).forEach (o) ->
      o.on_drag_end()

    return moved_objects.length > 0

  # moves the specified object (shape) a liitle amount if it overlaps some other objects
  # returns true if position changed
  move_a_bit: (a) ->
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

  init_viewbox: ->
    # dimensions of the svg node in display pixels
    r = @svg.getBoundingClientRect()
    m = r.right - r.left
    n = r.bottom - r.top

    @svg.setAttribute('viewBox', "#{-m/2} #{-n/2} #{m} #{n}")

  # updates svg viewbox according to dimensions of svg element on screen
  update_viewbox: (reset) ->
    # svg viewbox dimensions
    v = @svg.getAttribute('viewBox').split(' ')
    x = parseFloat(v[0])
    y = parseFloat(v[1])
    w = parseFloat(v[2])
    h = parseFloat(v[3])

    # dimensions of the svg node in display pixels
    r = @svg.getBoundingClientRect()
    m = r.right - r.left
    n = r.bottom - r.top

    # ratio of svg pixels to display pixels
    window.drag_scale = if m > n then (h / n) else (w / m)

    # set viewbox width and height
    if m > n
      @vbw = w
      @vbh = w * n / m
    else
      @vbh = h
      @vbw = h * m / n

    # set viewbox top-left corner
    @vbx = x + (w - @vbw) / 2
    @vby = y + (h - @vbh) / 2

    @svg.setAttribute('viewBox', "#{@vbx} #{@vby} #{@vbw} #{@vbh}") if reset

  # handle zoom-in/zoom-out on mouse wheel
  on_mousewheel: (e) ->
    @update_viewbox false

    s = if (e.originalEvent.deltaY ? -e.originalEvent.wheelDelta) < 0 then 1/1.1 else 1.1

    offsetX = e.originalEvent.layerX ? e.offsetX
    offsetY = e.originalEvent.layerY ? e.offsetY

    @vbw *= s
    @vbh *= s
    @vbx += offsetX * window.drag_scale * (1-s)
    @vby += offsetY * window.drag_scale * (1-s)

    @svg.setAttribute('viewBox', "#{@vbx} #{@vby} #{@vbw} #{@vbh}")

    e.stopPropagation()
    false

  # compute and set svg viewbox to fit content
  autofit: ->
    @update_viewbox false

    # get smallest bounding box of the svg node
    bb = @svg.getBBox()
    return if bb.width == 0 || bb.height == 0

    @vbx = bb.x
    @vby = bb.y

    u = @vbh / @vbw
    v = bb.height / bb.width

    if u > v
      @vbw = bb.width
      @vbh = @vbw * u
      @vby += (bb.height - @vbh) / 2

    else
      @vbh = bb.height
      @vbw = @vbh / u
      @vbx += (bb.width - @vbw) / 2

    @svg.setAttribute('viewBox', "#{@vbx} #{@vby} #{@vbw} #{@vbh}")
    @update_viewbox false

  post_render: ->
    @init_viewbox()
    @objects.forEach (view) ->
      view.post_render()
    @remove_overlaps()
    @autofit()
