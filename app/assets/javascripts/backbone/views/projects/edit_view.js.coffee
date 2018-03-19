Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.EditView extends Backbone.View
  template: JST["backbone/templates/projects/edit"]

  render: ->
    @$el.html @template(@model.toJSON())
    @

  show: (options) ->
    $('#edit-project-dialog').modal
      backdrop: 'static'
      keyboard: false

    .on 'shown.bs.modal', ->
      $('#new-project-title').focus()

    .on 'hidden.bs.modal', -> # triggered when dialog disappeared
      $('#edit-project-dialog').modal('dispose')

    .on 'save.bs.modal', => # triggered when apply button of the dialog is pushed
      # disable dialog buttons on start of sync
      $('#edit-project-dialog .btn-success').prop('disabled', true)
      $('#edit-project-dialog .btn-default').prop('disabled', true)

      @model.save
        title: $('#new-project-title').val()
        visibility: if $('#new-project-visibility').is(':checked') then 'public_project' else 'private_project'
        description: $('#new-project-description').val()
      ,
        wait: true
        pick: ['title', 'description', 'visibility']

        success: (model, response) ->
          $('#edit-project-dialog').modal('hide')
          options.success(model, response) if options.success

        error: (model, response) ->
          # call optional error handler
          options.error(model, response) if options.error

          # enable dialog buttons after sync
          $('#edit-project-dialog .btn-success').prop('disabled', false)
          $('#edit-project-dialog .btn-default').prop('disabled', false)

    # respond to title change
    $('#new-project-title').on "input propertychange", (e) ->
      $('#edit-project-dialog .btn-success').prop('disabled', e.target.value.length == 0)

    # respond to keyboard enter
    $('#new-project-title').keyup (e) ->
      $('#edit-project-dialog .btn-success').trigger('click') if e.keyCode == 13 && e.target.value.length > 0

    @
