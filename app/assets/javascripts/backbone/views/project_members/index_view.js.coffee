Taskscape.Views.ProjectMembers ||= {}

class Taskscape.Views.ProjectMembers.IndexView extends Backbone.View
  template: JST["backbone/templates/project_members/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (member) =>
    view = new Taskscape.Views.ProjectMembers.MemberView
      model : member
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html @template(members: @collection.toJSON())
    @addAll()

    return this
