Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.ShowView extends Backbone.View
  template: JST["backbone/templates/projects/show"]

  events:
    "mousewheel svg" : "on_mousewheel"

  initialize: ->
    @objects = []

  render: ->
    @$el.html(@template(@model.toJSON()))

    @$('.tappable').data('view_object', @)
    @svg = @$('svg')[0]

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
        window.dragging_view = $(e.target).data('view_object')
        window.dragging_view.$el.appendTo window.dragging_view.$el.parent()
        window.dragging_view.focus true
        window.dragging_view.on_drag_start()

        @update_viewbox()

      # call this function on every dragmove e
      onmove: (e) ->
        window.dragging_view.on_drag(e.dx * window.drag_scale, e.dy * window.drag_scale)

      # call this function on every dragend e
      onend: (e) =>
        # call object to save its new position only if remove_overlaps did not call it
        window.dragging_view.on_drag_end() unless @remove_overlaps()

    interact('.tappable').on 'tap', (e) =>
      if e.target.classList.contains('shadow')
        @focus true # treat shadow image as if it is not part of clicked object

      else
        $(e.currentTarget).data('view_object').focus true
        window.focused_view.$el.appendTo window.focused_view.$el.parent()

      e.stopPropagation()

    # update svg viewbox on resize
    $(window).resize =>
      @update_viewbox()

    return this

  focus: (focused) ->
    if focused
      if window.focused_view != @
        window.focused_view.focus false if window.focused_view
        window.focused_view = @

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

  # updates svg viewbox according to dimensions of svg element on screen
  update_viewbox: ->
    v = @svg.getAttribute('viewBox').split(' ')
    x = parseFloat(v[0])
    y = parseFloat(v[1])
    w = parseFloat(v[2])
    h = parseFloat(v[3])

    r = @svg.getBoundingClientRect()
    m = r.right - r.left
    n = r.bottom - r.top

    window.drag_scale = if m > n then (h / n) else (w / m)

    if m > n
      w_ = w
      h_ = w_ * n / m
    else
      h_ = h
      w_ = h_ * m / n

    @svg.setAttribute('viewBox', "#{x+(w-w_)/2} #{y+(h-h_)/2} #{w_} #{h_}")

  on_mousewheel: (e) ->
    v = @svg.getAttribute('viewBox').split(' ')
    x = parseFloat(v[0])
    y = parseFloat(v[1])
    w = parseFloat(v[2])
    h = parseFloat(v[3])

    r = @svg.getBoundingClientRect()
    m = r.right - r.left
    n = r.bottom - r.top

    window.drag_scale = if m > n then (h / n) else (w / m)

    s = if e.originalEvent.wheelDelta > 0 then 1/1.1 else 1.1
    xx = e.offsetX
    yy = e.offsetY

    w *= s
    h *= s
    x += xx * window.drag_scale * (1-s);
    y += yy * window.drag_scale * (1-s);

    @svg.setAttribute('viewBox', "#{x} #{y} #{w} #{h}")

  on_resize: (e) ->
    console.log hi