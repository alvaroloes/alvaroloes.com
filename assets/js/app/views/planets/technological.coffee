class MyUniverse.Views.Technological extends MyUniverse.Views.Planet
  template: JST['templates/planets/technological']
  className: 'technological'
  initialize: ->
    super

  render: ->
    super =>
      @$el.html(@template())
      @


