class MyUniverse.Views.Technological extends MyUniverse.Views.Planet
  template: JST['templates/planets/technological']
  className: 'technological'
  planetImg: 'assets/img/solarSystem/planets/technological.png'

  initialize: ->
    @orbitRadius = Config.technologicalOrbitRadius
    @orbitPeriod = Config.technologicalOrbitPeriod
    @personalColor = Config.technologicalColor
    super

  render: ->
    super =>
      @$el.html(@template())
      @

  paint: (ctx, cnv)->
    super

