class MyUniverse.Views.Labor extends MyUniverse.Views.Planet
  template: JST['templates/planets/labor']
  className: 'labor'
  initialize: ->
    super

  render: ->
    super =>
      @$el.html(@template())
      @


