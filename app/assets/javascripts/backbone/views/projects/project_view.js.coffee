Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.ProjectView extends Backbone.View
  template: JST["backbone/templates/projects/project"]

  initialize: ->
    @objects = []

    @listenTo @model.get('tasks'), 'add', (model, response, options) -> 
      @add_task(model)
      @remove_overlaps()

    @listenTo @model.get('tasks'), 'remove', (model, response, options) ->
      # remove view of removed task
      @objects = @objects.filter (o) -> o.model.id != model.id

      # restore other tasks to their original position (their position may have been changed to remove overlaps)
      @objects.forEach (o) -> o.move animation: true

  render: ->
    @$el.html @template(@model.toJSON()) if this instanceof Taskscape.Views.Projects.ProjectView

    @$('.tappable').data('view_object', @)
    @svg = @$('svg.canvas')

    # render tasks of this project (supertask)
    @model.get('tasks').forEach (t) => @add_task t

    @disable_interactions()
    return @

  add_task: (t) ->
    view = new Taskscape.Views.Tasks.ShowView
      model: t
      attributes: 
        transform: "translate(#{t.get('x')} #{t.get('y')})"

    @svg.append(view.render().el)

    @stopListening t
    @listenTo t, 'change:effort', (model, response, options) -> @remove_overlaps() # ensure no overlap if task size changes (as a consequence of changing effort)

    @objects.push view
    return view

  post_render: ->
    # initialize svg viewbox
    SVG.init_viewbox @svg

    # call post_render on all included views
    @objects.forEach (view) ->
      view.post_render()

    # resolve object overlaps
    @remove_overlaps animation: false

    # autofit content
    SVG.autofit @svg, true

  # this function re-arranges objects (shapes) so to ensure they do not overlap any other
  # returns true if arrangements changed
  remove_overlaps: (options) ->
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

    if !options? || (options.animation ? true)
      _.uniq(moved_objects).forEach (m) -> 
        x = m.x
        y = m.y
        # restore original position of objects, then move them to their new position by animation
        m.move().move x: x, y: y, animation: true #, save: !new_object_added

    options.cause.save_position() if options && options.cause
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

  # destroy all interactions
  disable_interactions: ->
    interact('.draggable').unset()
    interact('.dropzone').unset()
    interact('.pannable').unset()
    interact('img.member-avatar').unset()
    interact('#drop-task').unset()
    interact('.tappable').off('tap')
