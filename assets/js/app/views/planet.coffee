class MyUniverse.Views.Planet extends MyUniverse.Views.View

  initialize: ->
    @className = "planet #{@className}"
    @$el.addClass(@className)

  render: (next = $.noop) ->
    next()

  paint: (ctx,cnv)->
