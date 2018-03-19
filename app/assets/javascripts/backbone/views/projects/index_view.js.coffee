Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  events:
    "click #new-project-button" : "new_project"

  initialize: () ->
    @listenTo @collection, 'add', (model, response, options) -> @add(model)
    @listenTo @collection, 'remove', (model, response, options) -> @objects = @objects.filter (o) -> o.model.id != model.id

  addAll: () ->
    @collection.each @add

  add: (project) =>
    view = new Taskscape.Views.Projects.ProjectView
      model: project
      className: 'col-xs-12 col-md-6 col-lg-4 col-xl-3'

    @objects.push view
    @$("#projects-table").append(view.render().el)

  render: ->
    @$el.html @template(projects: @collection.toJSON())
    @objects = []
    @addAll()
    @

  post_render: ->
    @objects.forEach (o) -> o.post_render()

  new_project: ->
    # create a new project
    project = new Taskscape.Models.Project()

    view = new Taskscape.Views.Projects.EditView(model: project)
    @$('#modal-container').html view.render().el

    view.show
      success: (model) =>
        @collection.add model
        router.navigate "#/#{model.id}"
