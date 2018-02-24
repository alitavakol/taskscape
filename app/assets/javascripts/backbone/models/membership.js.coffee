class Taskscape.Models.Membership extends Backbone.Relational.Model
  paramRoot: 'membership'
  urlRoot: 'memberships'

  defaults:
    project_id: null
    member_id: null

Taskscape.Models.Membership.setup()
