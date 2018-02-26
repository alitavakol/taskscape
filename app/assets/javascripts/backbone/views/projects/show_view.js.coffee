Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.ShowView extends Backbone.View
  template: JST["backbone/templates/projects/show"]

  render: ->
    @$el.html(@template(@model.toJSON()))

    @$('.tappable').data('view_object', @)

    @model.get('tasks').forEach (t) =>
      view = new Taskscape.Views.Tasks.ShowView
        model: t
        tagName: 'g'
        attributes: 
          transform: "translate(#{t.get('x')} #{t.get('y')})"
      @$('svg').append(view.render().el)

    # enable dragging tasks
    interact('.draggable').draggable
      # allow dragging of multple elements at the same time
      max: Infinity
      inertia: false

      onstart: (e) ->
        window.dragging_view = $(e.target).data('view_object')
        window.dragging_view.$el.appendTo window.dragging_view.$el.parent()
        window.dragging_view.focus true
        window.dragging_view.on_drag_start()

      # call this function on every dragmove e
      onmove: (e) ->
        window.dragging_view.on_drag(e.dx, e.dy)

      # call this function on every dragend e
      onend: (e) ->
        window.dragging_view.on_drag_end()

    interact('.tappable').on 'tap', (e) ->
      $(e.currentTarget).data('view_object').focus true
      window.focused_view.$el.appendTo window.focused_view.$el.parent()
      e.stopPropagation()

    return this

  focus: (focused) ->
    if focused
      if window.focused_view != @
        window.focused_view.focus false if window.focused_view
        window.focused_view = @
