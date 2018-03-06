class Taskscape.Models.Membership extends Backbone.RelationalModel
  paramRoot: 'membership'
  urlRoot: 'memberships'

  defaults:
    project_id: null
    member_id: null

Taskscape.Models.Membership.setup()
