Taskscape.Views.Projects ||= {}
Taskscape.Views.Projects.Members ||= {}

class Taskscape.Views.Projects.Members.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/members/index"]

  tagName: "ul"

  events:
    "click #btn-add" : "add_member"

  initialize: ->
    @collection = @model.get('memberships')
    @collection.bind('reset', @addAll)

  addAll: ->
    @collection.each(@addOne)

  addOne: (member) =>
    view = new Taskscape.Views.Projects.Members.MemberView(model: member)
    view.project = @model

    @$el.append(view.render().el)
    @$('#btn-add').appendTo @$el # move add member button to bottom

  render: ->
    @$el.html @template(members: @collection.toJSON())
    @addAll()

    # enable dragging user avatars into tasks and other drop zones
    @enable_drag()

    # hide the native scrollbars and provide custom styleable overlay scrollbars
    # https://kingsora.github.io/OverlayScrollbars
    @$el.overlayScrollbars
      scrollbars: {autoHide: 'move'}

    return this

  # enable dragging user avatars into tasks and other drop zones
  enable_drag: ->
    interact('img.member-avatar, #drop-task').draggable
      max: 1 # allow dragging of multple elements at the same time
      inertia: false

      onstart: (e) ->
        $('#popover').popover('hide')

        @avatar = $(e.currentTarget) # the about-to-be-dragged element
        if @avatar.attr('id') == 'drop-task'
          drop_task = true

        # find position of the dragged avatar relative to #projects element
        top = 0 # if drop_task then 0 else -$('#munition-sidebar').height()
        left = 0
        el = @avatar.parent()
        while el.attr('id') != 'projects'
          p = el.position()
          top += p.top
          left += p.left
          el = el.parent()

        # clone the avatar and position it absolutely
        @clone = @avatar.clone()
        .addClass('dragging')
        .css
          position: 'absolute'
          top: top
          left: left
          width: @avatar.width()
          height: @avatar.height()
          "z-index": 1

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

  add_member: ->
    view = new Taskscape.Views.Projects.EditView(model: @model)
    view.add_member_dialog = true

    $('#modal-container').html view.render().el
    view.show()

    false # do not remove this
