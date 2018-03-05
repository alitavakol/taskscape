window.SVG =

  # initialize svg viewbox
  init_viewbox: (svg) ->
    # dimensions of the svg node in display pixels
    r = svg.getBoundingClientRect()
    m = r.right - r.left
    n = r.bottom - r.top

    svg.setAttribute('viewBox', "#{-m/2} #{-n/2} #{m} #{n}")

  # updates svg viewbox according to dimensions of svg element on screen
  update_viewbox: (svg, reset) ->
    # svg viewbox dimensions
    v = svg.getAttribute('viewBox').split(' ')
    x = parseFloat(v[0])
    y = parseFloat(v[1])
    w = parseFloat(v[2])
    h = parseFloat(v[3])

    # dimensions of the svg node in display pixels
    r = svg.getBoundingClientRect()
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

    svg.setAttribute('viewBox', "#{@vbx} #{@vby} #{@vbw} #{@vbh}") if reset

  # compute and set svg viewbox to fit content
  autofit: (svg, immediately) ->
    SVG.update_viewbox svg, false

    # get smallest bounding box of the svg node
    bb = svg.getBBox()
    return if bb.width == 0 || bb.height == 0

    vbx = bb.x
    vby = bb.y
    vbw = @vbw
    vbh = @vbh

    u = vbh / vbw
    v = bb.height / bb.width

    if u > v
      vbw = bb.width
      vbh = vbw * u
      vby += (bb.height - vbh) / 2

    else
      vbh = bb.height
      vbw = vbh / u
      vbx += (bb.width - vbw) / 2

    @change_viewbox svg, vbx, vby, vbw, vbh, immediately

  change_viewbox: (svg, vbx, vby, vbw, vbh, immediately) ->
    # no animation if immediately
    if immediately
      svg.setAttribute('viewBox', "#{vbx} #{vby} #{vbw} #{vbh}")
      SVG.update_viewbox svg, false
      return

    frames = if immediately then 1 else 10

    old_vbx = @vbx
    old_vby = @vby
    old_vbw = @vbw
    old_vbh = @vbh

    delta_x = (vbx - old_vbx) / frames
    delta_y = (vby - old_vby) / frames
    delta_w = (vbw - old_vbw) / frames
    delta_h = (vbh - old_vbh) / frames

    $(t: 1).animate t: frames, 
      step: (t) -> 
        svg.setAttribute('viewBox', "#{old_vbx + t * delta_x} #{old_vby + t * delta_y} #{old_vbw + t * delta_w} #{old_vbh + t * delta_h}")
        SVG.update_viewbox svg, false
      complete: ->
        # SVG.update_viewbox svg, true
    @

  zoom: (svg, e) ->
    SVG.update_viewbox svg, false

    s = if (e.originalEvent.deltaY ? -e.originalEvent.wheelDelta) < 0 then 1/1.1 else 1.1

    offsetX = e.originalEvent.layerX ? e.offsetX
    offsetY = e.originalEvent.layerY ? e.offsetY

    @vbw *= s
    @vbh *= s
    @vbx += offsetX * window.drag_scale * (1-s)
    @vby += offsetY * window.drag_scale * (1-s)

    svg.setAttribute('viewBox', "#{@vbx} #{@vby} #{@vbw} #{@vbh}")

    e.stopPropagation()
    false

  zoom_to: (object) ->
    svg = object.$el.closest('svg')[0]

    # object position
    bb = object.el.getBBox()
    left = bb.x + object.x
    top = bb.y + object.y
    right = left + bb.width
    bottom = top + bb.height

    vbx = left
    vby = top

    u = @vbh / @vbw
    v = bb.height / bb.width

    if u > v
      vbw = bb.width
      vbh = vbw * u
      vby = top + (bb.height - vbh) / 2

    else
      vbh = bb.height
      vbw = vbh / u
      vbx = left + (bb.width - vbw) / 2

    @change_viewbox svg, vbx, vby, vbw, vbh

  # update viewbox of svg to ensure the specified object is inside
  # returns true if viewbox changed
  ensure_visible: (object) ->
    svg = object.$el.closest('svg')[0]

    # object position
    bb = object.el.getBBox()
    left = bb.x + object.x
    top = bb.y + object.y
    right = left + bb.width
    bottom = top + bb.height

    vbx = @vbx
    vby = @vby
    vbw = @vbw
    vbh = @vbh

    u = vbh / vbw

    if @vbh < bb.height
      vbh = bb.height
      vbw = vbh / u
      changed = true

    if @vbw < bb.width
      vbw = bb.width
      vbh = vbw * u
      changed = true

    if left < vbx
      vbx = left
      changed = true
    else if right > vbx + vbw
      vbx = right - vbw
      changed = true

    if top < vby
      vby = top
      changed = true
    else if bottom > vby + vbh
      vby = bottom - vbh
      changed = true

    @change_viewbox svg, vbx, vby, vbw, vbh
    return changed ? false

  move: (svg, dx, dy) ->
    @vbx -= dx * window.drag_scale
    @vby -= dy * window.drag_scale
    svg.setAttribute('viewBox', "#{@vbx} #{@vby} #{@vbw} #{@vbh}")
