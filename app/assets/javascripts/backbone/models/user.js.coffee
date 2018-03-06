class Taskscape.Models.User extends Backbone.RelationalModel
  paramRoot: 'user'
  urlRoot: 'users'

  defaults:
    name: null

Taskscape.Models.User.setup()
