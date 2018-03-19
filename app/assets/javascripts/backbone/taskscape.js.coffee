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
    router.on 'route', (route, params) ->
      # destroy any open dialog on route change
      $('#edit-project-dialog').modal('dispose')
      $('body > .modal-backdrop').remove() # workaround

# https://www.npmjs.com/package/coffeescript-mixins
# Function::include = (mixin) ->
#   if not mixin
#     return throw 'Supplied mixin was not found'

#   mixin = mixin.prototype if _.isFunction(mixin)

#   # Make a copy of the superclass with the same constructor and use it instead of adding functions directly to the superclass.
#   if @.__super__
#     tmpSuper = _.extend({}, @.__super__)
#     tmpSuper.constructor = @.__super__.constructor

#   @.__super__ = tmpSuper || {}
  
#   # Copy function over to prototype and the new intermediate superclass.
#   for methodName, funct of mixin when methodName not in ['included']
#     @.__super__[methodName] = funct

#     if not @prototype.hasOwnProperty(methodName)
#       @prototype[methodName] = funct

#   mixin.included?.apply(this)
#   this


# override the Backbone.sync to send only the changed fields for update (PUT) request
Original_BackboneSync = Backbone.sync

Backbone.sync = (method, model, options) ->
  # custom behavior if pick option is provided
  if options && options.pick
    model = jQuery.extend({}, model) # clone
    model.attributes = _.pick(model.attributes, options.pick, '__proto__', 'uid', 'id')

  # if (options && options.pick) || method != 'read'
  #   model.attributes['uid'] = window.uid # server response should resend this UID as is

  # invoke the original backbone sync method
  Original_BackboneSync.apply(this, arguments)


# https://github.com/jashkenas/backbone/issues/630
$.ajaxSetup
  cache: false

$(document).keyup (e) ->
  $('#popover').popover('hide') if e.keyCode == 27 # hide any open popover dialog

# global ajax error handler
# shows a toast notification
$(document).ajaxError (e, jqxhr, settings, thrownError) ->
  # console.log e
  # console.log jqxhr
  # console.log settings
  # console.log thrownError
  if jqxhr
    if jqxhr.responseText
      if jqxhr.status == 422
        for attribute, messages of jqxhr.responseJSON
          toastr["error"]("#{attribute} #{message}", "#{thrownError} (#{jqxhr.status})") for message in messages

      else # some response error other than 422
        toastr["error"](jqxhr.responseJSON.error || jqxhr.responseText, "#{thrownError} (#{jqxhr.status})")

    else # network error
      toastr["error"]("Could not connect to server", "Network Error")

  @

$('main').click (e) ->
  # hide any open popover dialog if clicked an element that is not a child of the popover dialog element
  $('#popover').popover('hide') unless $(e.target).closest('.popover').length
