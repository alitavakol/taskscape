# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
# vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file. JavaScript code in this file should be added after the last require_* statement.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery3
#= require popper
#= require rails-ujs
#= require bootstrap-sprockets
#= require underscore-min
#= require backbone
#= require backbone-relational-modified
#= require backbone_rails_sync
#= require backbone_datalink
#= require backbone/taskscape
#= require tinycolor-min
#= require interact
#= require jquery.overlayScrollbars.min.js
#= require toastr
#= require nprogress
#= require nprogress-ajax
#= require_tree .

# NProgress.configure
#   showSpinner: false

# http://codeseven.github.io/toastr/demo.html
toastr.options =
  closeButton: false
  debug: false
  newestOnTop: false
  progressBar: false
  positionClass: "toast-bottom-right"
  preventDuplicates: false
  onclick: null
  showDuration: "100"
  hideDuration: "200"
  timeOut: "3000"
  extendedTimeOut: "1000"
  showEasing: "swing"
  hideEasing: "linear"
  showMethod: "fadeIn"
  hideMethod: "fadeOut"
