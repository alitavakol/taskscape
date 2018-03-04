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
  autofit: (svg) ->
    SVG.update_viewbox svg, false

    # get smallest bounding box of the svg node
    bb = svg.getBBox()
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

    svg.setAttribute('viewBox', "#{@vbx} #{@vby} #{@vbw} #{@vbh}")
    SVG.update_viewbox svg, false

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

  move: (svg, dx, dy) ->
    @vbx -= dx * window.drag_scale
    @vby -= dy * window.drag_scale
    svg.setAttribute('viewBox', "#{@vbx} #{@vby} #{@vbw} #{@vbh}")
