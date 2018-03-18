Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  initialize: () ->
    @objects = []

  addAll: () ->
    @collection.each @addOne

  addOne: (project) =>
    view = new Taskscape.Views.Projects.ProjectView
      model: project
      className: 'col-xs-12 col-md-6 col-lg-4 col-xl-3'

    @objects.push view
    @$("#projects-table").append(view.render().el)

  render: ->
    @$el.html @template(projects: @collection.toJSON())
    @addAll()
    @

  post_render: ->
    @objects.forEach (o) -> o.post_render()
