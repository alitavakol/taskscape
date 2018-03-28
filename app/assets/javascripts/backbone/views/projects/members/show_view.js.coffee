Taskscape.Views.Projects ||= {}
Taskscape.Views.Projects.Members ||= {}

class Taskscape.Views.Projects.Members.ShowView extends Backbone.View
  template: JST["backbone/templates/projects/members/show"]

  render: (options) ->
    $('#popover').trigger('hidden.bs.popover').popover('dispose').popover
      title: 'Member details'
      content: @template(@model.toJSON())
      html: true
      placement: 'right'
      trigger: 'focus'

    .css # place the dialog on click location
      top: options.y
      left: options.x

    .popover('show')

    .on 'hidden.bs.popover', -> # triggered when dialog disappeared

    # .on 'save.bs.popover', => # triggered when save button of the dialog is pushed
    #   # save task with provided title and color
    #   task.save {}, 
    #     pick: ['title', 'x', 'y', 'color', 'supertask_id', 'description']
    #     error: (model, response) -> 
    #       # restore original model attributes
    #       model.set
    #         title: attributes.title
    #         color: attributes.color
    #         description: attributes.description

    #       # call optional handler
    #       options.error(model, response) if options.error

    #   # close the popover dialog
    #   $('#popover').popover('dispose')

    # # respond to keyboard enter
    # $('#new-task-title').keyup (e) ->
    #   if e.keyCode == 13 && e.target.value.length > 0
    #     $('.popover .btn-success').trigger 'click'
    #     return

    @
