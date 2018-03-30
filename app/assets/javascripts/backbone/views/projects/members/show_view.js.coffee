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

    $('.popover .btn-delete').off('click').on 'click', =>
      @delete_membership()
      $('#popover').popover('dispose')
      false

    $('.popover .btn-invite').off('click').on 'click', =>
      @re_invite()
      $('#popover').popover('dispose')
      false

    @

  delete_membership: ->
    @model.destroy wait: true
    false

  re_invite: ->
    # just tell server to add this user as a new member.
    # server will invite them.
    @project.save
      member_tokens: "<<<#{@model.get('email')}>>>"
    ,
      wait: true
      pick: ['member_tokens']
      success: (model, response) =>
        toastr["info"]("A sign-up request just sent to #{@model.get('name')}.", "Invitation sent")

    false
