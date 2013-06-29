class MyUniverse.Views.Reflexive extends MyUniverse.Views.Planet
  template: JST['templates/planets/reflexive']
  className: 'reflexive'
  initialize: ->
    super

  render: ->
    super =>
      @$el.html(@template())
      @


