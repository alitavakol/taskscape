Taskscape.Views.Tasks ||= {}

class Taskscape.Views.Tasks.DetailsView extends Backbone.View
  template: JST["backbone/templates/tasks/details"]

  events:
    "click .title .fa-pencil" : "edit_title"
    "blur .title input"       : "cancel_edit_title"
    "keyup .title input"      : "accept_edit_title"
    "click i.clickable"       : "change_attribute"

  initialize: ->
    @listenTo @model, 'change', (model, response, options) -> @render()

  render: ->
    @$el.html @template(@model.toJSON())
    @

  edit_title: ->
    @$('.title .label-container').hide()
    @$('.title input').show().focus().val @$('.title .label').html()
    @

  cancel_edit_title: ->
    @$('.title .label-container').show()
    @$('.title input').hide()
    @

  accept_edit_title: (e) ->
    return @cancel_edit_title() if e.keyCode == 27
    return unless e.keyCode == 13

    @model.save
      title: @$('.title input').val()
    ,
      pick: ['title']

    @cancel_edit_title()

  change_attribute: (e) ->
    attribute = $(e.currentTarget).parent().data('attribute')
    value = $(e.currentTarget).data('value')
    @model.save JSON.parse("{\"#{attribute}\": \"#{value}\"}"), pick: [attribute]
