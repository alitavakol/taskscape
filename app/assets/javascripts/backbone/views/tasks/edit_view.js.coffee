Taskscape.Views.Tasks ||= {}

class Taskscape.Views.Tasks.EditView extends Backbone.View
  template: JST["backbone/templates/tasks/edit"]

  # present a dialog to user to enter title and color of the new task
  render: (task, options) ->
    # backup original model attributes
    attributes = _.clone task.attributes

    $('#popover').popover
      title: 'Create a new task'
      content: @template(task.toJSON())
      html: true
      placement: options.popover_placement || 'auto'
      trigger: 'focus'

    .css # place the dialog on drop location
      top: options.y
      left: options.x

    .popover('show')

    # .on 'shown.bs.popover', -> console.log 'shown.bs.popover'

    .on 'hidden.bs.popover', => # triggered when dialog disappeared
      $('#popover').popover('dispose')

      # restore original model attributes
      task.set
        title: attributes.title
        color: attributes.color

      # call optional handler
      options.cancel() if options.cancel

    .on 'save.bs.popover', => # triggered when save button of the dialog is pushed
      # save task with provided title and color
      task.save {}, 
        pick: ['title', 'x', 'y', 'color', 'supertask_id']
        error: (model, response) -> 
          # restore original model attributes
          model.set
            title: attributes.title
            color: attributes.color

          # call optional handler
          options.error(model, response) if options.error

      # close the popover dialog
      $('#popover').popover('dispose')

    $('#new-task-title').focus()

    # respond to color pick
    $('#color-tool div').click (e) ->
      $('#color-tool div').removeClass('fa fa-check')
      $(e.target).addClass('fa fa-check')
      task.set color: "##{e.target.id.substr(6)}"

    # respond to title change
    $('#new-task-title').on "input propertychange", (e) ->
      task.set title: e.target.value
      $('.popover .btn-success').prop('disabled', e.target.value.length == 0)

    # respond to keyboard enter
    $('#new-task-title').keyup (e) ->
      if e.keyCode == 13 && e.target.value.length > 0
        $('#popover').trigger('save.bs.popover')
        return

  @
