class MyUniverse.Views.Tech extends MyUniverse.Views.Planet
  template: JST['templates/planets/tech']
  className: 'tech'
  planetImg: 'assets/img/solarSystem/planets/tech.png'
  planetTexture: 'assets/img/solarSystem/planets/textures/tech.png'
  planetGlowMap: 'assets/img/solarSystem/planets/textures/tech_glow_map.jpg'

  initialize: (@opt)->
    super
    @paintStrategy.orbitRadius = Config.techOrbitRadius
    @paintStrategy.orbitPeriod = Config.techOrbitPeriod
    @paintStrategy.selfRotationPeriod = Config.techSelfRotationPeriod
    @paintStrategy.selfRotationDirection = -1
    @paintStrategy.planetColor = Config.techColor
    @paintStrategy.planetImg = @planetImg
    @paintStrategy.planetTexture = @planetTexture
    @paintStrategy.glowMap = @planetGlowMap

  render: ->
    super =>
      @$el.html(@template(t: i18n.t))

