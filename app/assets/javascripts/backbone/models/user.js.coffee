class Taskscape.Models.User extends Backbone.Relational.Model
  paramRoot: 'user'
  urlRoot: 'users'

  defaults:
    name: null

Taskscape.Models.User.setup()