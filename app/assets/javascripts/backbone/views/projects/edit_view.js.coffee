Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.EditView extends Backbone.View
  template: JST["backbone/templates/projects/edit"]

  initialize: ->
    # variable indicating whether this dialog is opened for adding new members to the project
    @add_member_dialog = false

  render: (options) ->
    @$el.html @template _.extend @model.toJSON(), add_member_dialog: @add_member_dialog
    @

  show: (options) ->
    options ?= {}

    $('#edit-project-dialog').modal('dispose').modal
      backdrop: 'static'
      keyboard: false

    .off('shown.bs.modal').on 'shown.bs.modal', =>
      (if @add_member_dialog then $('.modal-dlg input') else $('#new-project-title')).focus()

    .off('save.bs.modal').on 'save.bs.modal', => # triggered when apply button of the dialog is pushed
      # disable dialog buttons on start of sync
      $('#edit-project-dialog .btn-success').prop('disabled', true)
      $('#edit-project-dialog .btn-default').prop('disabled', true)

      @model.save
        title: $('#new-project-title').val()
        visibility: if $('#new-project-visibility').is(':checked') then 'public_project' else 'private_project'
        description: $('#new-project-description').val()
        member_tokens: $('#member-tokens').val()
      ,
        wait: true
        pick: ['title', 'description', 'visibility', 'member_tokens']

        success: (model, response) ->
          window.close_dialogs()
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

    @$('#member-tokens').tokenInput "/users.json",
      theme: 'facebook'
      hintText: 'type to search'
      preventDuplicates: true
      minChars: 3
      hintText: 'Type name or email to add new project members'

    $(".token-input-dropdown-facebook").detach().appendTo('#edit-project-dialog')

    @
