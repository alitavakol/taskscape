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

    @

  delete_membership: ->
    @model.destroy wait: true
    false
