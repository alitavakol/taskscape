Taskscape.Views.Projects ||= {}
Taskscape.Views.Projects.Members ||= {}

class Taskscape.Views.Projects.Members.MemberView extends Backbone.View
  template: JST["backbone/templates/projects/members/member"]

  events:
    "click .destroy" : "destroy"

  tagName: "li"
  className: 'member-avatar'

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    @$el.html @template(@model.toJSON())
    @$('img').data('view_object', @)
    @
