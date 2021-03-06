class MyUniverse.Views.Labor extends MyUniverse.Views.Planet
  template: JST['templates/planets/labor']
  className: 'labor'
  planetImg: 'assets/img/solarSystem/planets/labor.png'
  planetTexture: 'assets/img/solarSystem/planets/textures/labor.jpg'
  bumpMap: 'assets/img/solarSystem/planets/textures/labor_bump_map.jpg'

  initialize: (@opt)->
    super
    @paintStrategy.orbitRadius = Config.laborOrbitRadius
    @paintStrategy.orbitPeriod = Config.laborOrbitPeriod
    @paintStrategy.selfRotationPeriod = Config.laborSelfRotationPeriod
    @paintStrategy.selfRotationDirection = -1
    @paintStrategy.selfRotationDirection = -1
    @paintStrategy.selfRotationDeflection = -Math.PI / 8
    @paintStrategy.planetColor = Config.laborColor
    @paintStrategy.planetImg = @planetImg
    @paintStrategy.planetTexture = @planetTexture
    @paintStrategy.bumpMap = @bumpMap

  render: ->
    super =>
      @$el.html(@template(t: i18n.t))

