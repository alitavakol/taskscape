window.SVG =

  # initialize svg viewbox
  init_viewbox: (svg) ->
    # dimensions of the svg node in display pixels
    m = svg.width()
    n = svg.height()
    SVG.update_viewbox_variables svg, -m/2, -n/2, m, n, true

  # set global variables @vb? that hold svg viewbox dimensions to specified arguments
  # and ensure aspect ratio is equal to aspect ratio of svg in display pixels
  # and reset ratio of svg length to svg length in pixels, which is required for distance computation while dragging objects (drag_scale)
  update_viewbox_variables: (svg, vbx, vby, vbw, vbh, apply) ->
    # set function argument defaults if not provided
    unless vbx
      vbx = @vbx
      vby = @vby
      vbw = @vbw
      vbh = @vbh
      apply = true
      resized = true

    @vbx = vbx
    @vby = vby

    u = svg.width() / svg.height() # svg aspect ratio on screen
    v = vbw / vbh # new aspect ratio on svg space, which in the following code we are going to make equal to u

    # if required, add padding to new dimension to preserve aspect ratio
    if u > v || resized # new viewbox is taller; so add extra space to the top and bottm
      @vbx -= (vbh * u - vbw) / 2
      @vbw = vbh * u
      @vbh = vbh

    else # new viewbox is wider; add extra space to the left and right
      @vby -= (vbw / u - vbh) / 2
      @vbw = vbw
      @vbh = vbw / u

    @drag_scale = @vbw / svg.width() # normalization factor for conversion of mouse location change to svg space

    if apply
      svg.attr viewBox: "#{@vbx} #{@vby} #{@vbw} #{@vbh}"
      svg.trigger 'viewbox_changed'

  # changes svg viewbox by animation (optional), 
  # returns true if changed
  change_viewbox: (svg, vbx, vby, vbw, vbh, no_animation) ->
    old_vbx = @vbx
    old_vby = @vby
    old_vbw = @vbw
    old_vbh = @vbh

    @update_viewbox_variables svg, vbx, vby, vbw, vbh, no_animation

    # no animation if immediately
    return if no_animation

    frames = 10 # animation frame count

    delta_x = (vbx - old_vbx) / frames
    delta_y = (vby - old_vby) / frames
    delta_w = (vbw - old_vbw) / frames
    delta_h = (vbh - old_vbh) / frames

    $(t: 1).animate t: frames, 
      step: (t) -> 
        svg.attr viewBox: "#{old_vbx + t * delta_x} #{old_vby + t * delta_y} #{old_vbw + t * delta_w} #{old_vbh + t * delta_h}"
        svg.trigger 'viewbox_changed'

    return Math.abs(old_vbw - @vbw) > .01 * @vbw || Math.abs(old_vbh - @vbh) > .01 * @vbh || Math.abs(old_vbx - @vbx) > .01 * Math.abs(@vbx) || Math.abs(old_vby - @vby) > .01 * Math.abs(@vby)

  # zoom the svg by changing its viewbox, depending on mousewheel event e
  zoom: (svg, e) ->
    s = if (e.originalEvent.deltaY ? -e.originalEvent.wheelDelta) < 0 then 1/1.1 else 1.1
    offsetX = e.originalEvent.layerX ? e.offsetX
    offsetY = e.originalEvent.layerY ? e.offsetY

    vbw = @vbw * s
    vbh = @vbh * s
    vbx = @vbx + offsetX * @drag_scale * (1-s)
    vby = @vby + offsetY * @drag_scale * (1-s)

    SVG.update_viewbox_variables svg, vbx, vby, vbw, vbh, true

    e.stopPropagation()
    false

  # fit content of the svg to completely fill available space
  autofit: (svg, no_animation) ->
    margin_right = svg.data('padding-right') ? 0
    margin_left = svg.data('padding-left') ? 0
    display_width = svg.width()

    r = margin_right / display_width
    l = margin_left / display_width

    # object position
    bb = svg[0].getBBox()
    return if bb.width == 0 || bb.height == 0

    vbw = bb.width / (1 - l - r)
    vbh = bb.height
    vbx = bb.x - l * vbw
    vby = bb.y

    @change_viewbox svg, vbx, vby, vbw, vbh, no_animation

  # zoom svg by changing its viewbox to the specified svg group
  zoom_to: (g, translate_x, translate_y) ->
    svg = g.closest('svg')

    margin_right = svg.data('padding-right') ? 0
    margin_left = svg.data('padding-left') ? 0
    display_width = svg.width()

    r = margin_right / display_width
    l = margin_left / display_width

    # object position
    bb = g[0].getBBox()

    vbw = bb.width / (1 - l - r)
    vbh = bb.height
    vbx = bb.x + (translate_x ? 0) - l * vbw
    vby = bb.y + (translate_y ? 0)

    @change_viewbox svg, vbx, vby, vbw, vbh

  # update viewbox of the specified svg group to ensure inside viewbox
  # returns true if viewbox changed
  ensure_visible: (g, translate_x, translate_y, no_animation) ->
    svg = g.closest('svg')

    margin_right = svg.data('padding-right') ? 0
    margin_left = svg.data('padding-left') ? 0
    display_width = svg.width()
    display_height = svg.height()

    r = margin_right / display_width
    l = margin_left / display_width

    # object position
    bb = g[0].getBBox()

    width = bb.width
    height = bb.height
    left = bb.x + translate_x
    top = bb.y + translate_y
    right = left + width
    bottom = top + height

    vbx = @vbx
    vby = @vby
    vbw = @vbw
    vbh = @vbh

    u = display_width / display_height

    if vbh < height
      vbh = height
      vbw = vbh * u

    if width > vbw * (1-r-l)
      vbw = width / (1-r-l)
      vbh = vbw / u

    if left < vbx + l * vbw
      vbx = left - l * vbw
    else if right > vbx + vbw * (1-r)
      vbx = right - vbw * (1-r)

    if top < vby
      vby = top
    else if bottom > vby + vbh
      vby = bottom - vbh

    @change_viewbox svg, vbx, vby, vbw, vbh, no_animation

  # pan the specified svg element
  move: (svg, dx, dy) ->
    @vbx -= dx * @drag_scale
    @vby -= dy * @drag_scale
    svg.attr viewBox: "#{@vbx} #{@vby} #{@vbw} #{@vbh}"
    svg.trigger 'viewbox_changed'
