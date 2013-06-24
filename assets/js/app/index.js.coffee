#= require_self
#= require_tree .

window.Universe =
  Controllers: {}
  Models: {}
  Collection: {}
  Views: {}

$ ->
  # Instatiate controllers
  new Universe.Controllers.Sun()
  Backbone.history.start({pushState: true})