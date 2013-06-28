class MyUniverse.Controllers.Controller extends Backbone.Router
  init: (next = $.noop) ->
    unless MyUniverse.views.universe?
      MyUniverse.views.universe = univ =new MyUniverse.Views.Universe(useCanvas: true)
      $('#superuniverse').html(univ.el)
      univ.render()
    next()