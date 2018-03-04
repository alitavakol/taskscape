#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

window.Taskscape =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}

  initialize: ->

# https://www.npmjs.com/package/coffeescript-mixins
Function::include = (mixin) ->
  if not mixin
    return throw 'Supplied mixin was not found'

  mixin = mixin.prototype if _.isFunction(mixin)

  # Make a copy of the superclass with the same constructor and use it instead of adding functions directly to the superclass.
  if @.__super__
    tmpSuper = _.extend({}, @.__super__)
    tmpSuper.constructor = @.__super__.constructor

  @.__super__ = tmpSuper || {}
  
  # Copy function over to prototype and the new intermediate superclass.
  for methodName, funct of mixin when methodName not in ['included']
    @.__super__[methodName] = funct

    if not @prototype.hasOwnProperty(methodName)
      @prototype[methodName] = funct

  mixin.included?.apply(this)
  this


# override the Backbone.sync to send only the changed fields for update (PUT) request
Original_BackboneSync = Backbone.sync

Backbone.sync = (method, model, options) ->
  # custom behavior if pick option is provided
  if (options.pick)
    model = jQuery.extend({}, model) # clone
    model.attributes = _.pick(model.attributes, options.pick, '__proto__', 'uid', 'id')

  if (options.pick || method != 'read')
    model.attributes['uid'] = window.uid # server response should resend this UID as is

  # invoke the original backbone sync method
  Original_BackboneSync.apply(this, arguments)


# https://github.com/jashkenas/backbone/issues/630
$.ajaxSetup
  cache: false
