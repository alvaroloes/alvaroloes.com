class MyUniverse.Views.Labor extends MyUniverse.Views.Planet
  template: JST['templates/planets/labor']
  className: 'labor'
  planetImg: 'assets/img/solarSystem/planets/labor.png'

  initialize: ->
    @orbitRadius = Config.laborOrbitRadius
    @orbitPeriod = Config.laborOrbitPeriod
    @selfRotationPeriod = Config.laborSelfRotationPeriod
    @selfRotationDirection = -1
    @personalColor = Config.laborColor
    super

  render: ->
    super =>
      @$el.html(@template())
      @

  paint: (ctx, cnv)->
    super

