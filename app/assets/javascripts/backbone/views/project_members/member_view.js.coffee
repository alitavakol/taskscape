Taskscape.Views.ProjectMembers ||= {}

class Taskscape.Views.ProjectMembers.MemberView extends Backbone.View
  template: JST["backbone/templates/project_members/member"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    @$el.html @template(@model.toJSON())
    return this
