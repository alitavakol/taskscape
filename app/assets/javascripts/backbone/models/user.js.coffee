class Taskscape.Models.User extends Backbone.RelationalModel
  paramRoot: 'user'
  urlRoot: 'users'

  defaults:
    name: null
    avatar: null

Taskscape.Models.User.setup()
