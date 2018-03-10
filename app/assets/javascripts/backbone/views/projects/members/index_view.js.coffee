Taskscape.Views.Projects ||= {}
Taskscape.Views.Projects.Members ||= {}

class Taskscape.Views.Projects.Members.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/members/index"]

  tagName: "ul"
  className: "container-fluid"

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (member) =>
    view = new Taskscape.Views.Projects.Members.MemberView
      model: member
    @$el.append(view.render().el)

  render: =>
    @$el.html @template(members: @collection.toJSON())
    @addAll()

    # enable dragging user avatars into tasks and other drop zones
    @enable_drag()

    return this

  # enable dragging user avatars into tasks and other drop zones
  enable_drag: ->
    interact('img.member-avatar, #drop-task').draggable
      max: 1 # allow dragging of multple elements at the same time
      inertia: false

      onstart: (e) ->
        @avatar = $(e.currentTarget) # the about-to-be-dragged element
        if @avatar.attr('id') == 'drop-task'
          drop_task = true

        # find position of the dragged avatar relative to #projects element
        top = if drop_task then 0 else -$('#munition-sidebar').height()
        left = 0
        el = @avatar.parent()
        while el.attr('id') != 'projects'
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

        # insert the clone into #projects element
        @avatar.closest('#projects').append @clone

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
        @avatar.fadeTo 100, 1
        @clone.fadeOut 
          duration: 100
          complete: => @clone.remove()
        @avatar = null
