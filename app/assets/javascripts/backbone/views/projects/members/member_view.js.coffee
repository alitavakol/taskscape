Taskscape.Views.Projects ||= {}
Taskscape.Views.Projects.Members ||= {}

class Taskscape.Views.Projects.Members.MemberView extends Backbone.View
  template: JST["backbone/templates/projects/members/member"]

  events:
    "click" : "show_member_details"

  tagName: "li"

  initialize: ->
    @listenTo @model, 'destroy', -> @remove()
    dispatcher.on 'close', @close, @ # https://stackoverflow.com/a/9963360/1994239

  close: ->
    @remove()
    dispatcher.off 'close' # https://stackoverflow.com/a/9963360/1994239

  render: ->
    @$el.html @template(@model.toJSON())
    @$('img').data('view_object', @)
    @

  show_member_details: (e) ->
    view = new Taskscape.Views.Projects.Members.ShowView(model: @model)
    view.project = @project

    rc = e.currentTarget.getBoundingClientRect()

    view.render
      x: rc.right - 8
      y: rc.top - 16
