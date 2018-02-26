Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.ShowView extends Backbone.View
  template: JST["backbone/templates/projects/show"]

  events:
    "mousewheel svg" : "mousewheel"

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

        v = @svg.getAttribute('viewBox').split(' ')
        x = parseFloat(v[0])
        y = parseFloat(v[1])
        w = parseFloat(v[2])
        h = parseFloat(v[3])

        r = @svg.getBoundingClientRect()
        w2 = r.right - r.left
        h2 = r.bottom - r.top

        window.drag_scale = if w2 > h2 then (h / h2) else (w / w2)

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

  mousewheel: (e) ->
    v = @svg.getAttribute('viewBox').split(' ')
    x = parseFloat(v[0])
    y = parseFloat(v[1])
    w = parseFloat(v[2])
    h = parseFloat(v[3])

    r = @svg.getBoundingClientRect()
    m = r.right - r.left
    n = r.bottom - r.top

    window.drag_scale = if m > n then (h / n) else (w / m)

    s = 1
    xx = e.offsetX * drag_scale
    yy = e.offsetY * drag_scale

    w *= s
    h *= s

    # @svg.setAttribute('viewBox', "#{x+(x-xx)*s} #{y+(yy-y)*s} #{w*s} #{h*s}")
