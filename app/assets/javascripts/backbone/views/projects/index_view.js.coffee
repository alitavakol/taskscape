Taskscape.Views.Projects ||= {}

class Taskscape.Views.Projects.IndexView extends Backbone.View
  template: JST["backbone/templates/projects/index"]

  events:
    "click .btn-new" : "new_project"

  initialize: () ->
    @listenTo @collection, 'add', (model, response, options) -> @add(model)
    @listenTo @collection, 'remove', (model, response, options) -> @objects = @objects.filter (o) -> o.model.cid != model.cid
    dispatcher.on 'close', @close, @ # https://stackoverflow.com/a/9963360/1994239

  close: ->
    @remove()
    dispatcher.off 'close' # https://stackoverflow.com/a/9963360/1994239

  addAll: () ->
    @collection.each @add

  add: (project) =>
    view = new Taskscape.Views.Projects.ProjectView
      model: project
      className: 'col-xs-12 col-md-6 col-lg-4 col-xl-3'

    @objects.push view
    @$("#projects-list").append(view.render().el)

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
    $('#modal-container').html view.render().el

    view.show
      success: (model) =>
        @collection.add model
        router.navigate "#/#{model.id}"
