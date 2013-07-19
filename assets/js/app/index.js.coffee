#= require_tree ./config
#= require_self
#= require ./controllers/controller
#= require ./views/view
#= require_tree .

window.MyUniverse =
  Controllers: {}
  Models: {}
  Collection: {}
  Views: {}
  # Instances
  views: {}

$ ->
  # Instatiate controllers
  new MyUniverse.Controllers.Sun()

  # Instantiate views


  Backbone.history.start({pushState: true})