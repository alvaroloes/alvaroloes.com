class MyUniverse.Views.Tech extends MyUniverse.Views.Planet
  template: JST['templates/planets/tech']
  className: 'tech'
  planetImg: 'assets/img/solarSystem/planets/tech.png'

  initialize: ->
    @orbitRadius = Config.techOrbitRadius
    @orbitPeriod = Config.techOrbitPeriod
    @selfRotationPeriod = Config.techSelfRotationPeriod
    @selfRotationDirection = -1
    @planetColor = Config.techColor
    super

  render: ->
    super =>
      @$el.html(@template())

  paint: (ctx, cnv)->
    super
