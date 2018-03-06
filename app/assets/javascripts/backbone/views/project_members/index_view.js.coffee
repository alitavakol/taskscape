Taskscape.Views.ProjectMembers ||= {}

class Taskscape.Views.ProjectMembers.IndexView extends Backbone.View
  template: JST["backbone/templates/project_members/index"]

  tagName: "ul"
  className: "container-fluid"

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (member) =>
    view = new Taskscape.Views.ProjectMembers.MemberView
      model : member
    @$el.append(view.render().el)

  render: =>
    @$el.html @template(members: @collection.toJSON())
    @addAll()

    # enable dragging user avatars into tasks and other drop zones
    @enable_drag()

    return this

  # enable dragging user avatars into tasks and other drop zones
  enable_drag: ->
    interact('.member-avatar img').draggable
      max: Infinity # allow dragging of multple elements at the same time
      inertia: false

      onstart: (e) ->
        @avatar = $(e.currentTarget) # the about-to-be-dragged element

        # find position of the dragged avatar relative to #project-container element
        top = 0
        left = 0
        el = @avatar.parent()
        while el.attr('id') != 'project-container'
          p = el.position()
          top += p.top
          left += p.left
          el = el.parent()

        # clone the avatar and position it absolutely
        @clone = @avatar.clone().css
          position: 'absolute'
          top: top
          left: left
          width: @avatar.width()
          height: @avatar.height()

        # insert the clone into #project-container element
        @avatar.closest('#project-container').append @clone

        # make original user avatar image transparent
        @avatar.css opacity: .5
        @

      # call this function on every dragmove e
      onmove: (e) ->
        # move the clone accordingly
        @clone.css
          top: "#{e.dy + parseInt @clone.css('top')}px"
          left: "#{e.dx + parseInt @clone.css('left')}px"

      # call this function on every dragend e
      onend: (e) ->
        @avatar.fadeTo 200, 1
        @clone.fadeOut 
          duration: 200
          complete: => @clone.remove()
