Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (project) =>
    view = new Taskscape.Views.Projects.ProjectView({model : project})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(projects: @collection.toJSON() ))
    @addAll()

    return this
