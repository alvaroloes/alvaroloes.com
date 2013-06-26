class MyUniverse.Controllers.Controller extends Backbone.Router
  init: (next = $.noop) ->
    unless MyUniverse.views.universe?
      MyUniverse.views.universe = new MyUniverse.Views.Universe().render()
      $('#superuniverse').html(MyUniverse.views.universe.el)

    next()