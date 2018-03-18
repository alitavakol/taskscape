Taskscape.Views.Tasks ||= {}

class Taskscape.Views.Tasks.DetailsView extends Backbone.View
  template: JST["backbone/templates/tasks/details"]

  events:
    "click .title .fa-pencil" : "edit_title"
    "click i.clickable"       : "change_attribute"

  initialize: ->
    @listenTo @model, 'change', (model, response, options) -> @render()

  render: ->
    @$el.html @template(@model.toJSON())
    @

  edit_title: (e) ->
    @edit_task_view ||= new Taskscape.Views.Tasks.EditView()
    @edit_task_view.render @model, 
      x: e.clientX
      y: e.clientY + 20 - $('main').position().top
      popover_placement: 'bottom'
    @

  change_attribute: (e) ->
    attribute = $(e.currentTarget).parent().data('attribute')
    value = $(e.currentTarget).data('value')

    @model.save JSON.parse("{\"#{attribute}\": \"#{value}\"}"), 
      pick: [attribute]
      previous_value: @model.get(attribute)
      error: (model, response, options) ->
        model.set JSON.parse("{\"#{attribute}\": \"#{options.previous_value}\"}")
