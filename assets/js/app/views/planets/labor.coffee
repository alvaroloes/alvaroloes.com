class MyUniverse.Views.Labor extends MyUniverse.Views.Planet
  template: JST['templates/planets/labor']
  className: 'labor'
  planetImg: 'assets/img/solarSystem/planets/labor.png'
  planetTexture: 'assets/img/solarSystem/planets/textures/labor.jpg'

  initialize: (@opt)->
    super
    @paintStrategy.orbitRadius = Config.laborOrbitRadius
    @paintStrategy.orbitPeriod = Config.laborOrbitPeriod
    @paintStrategy.selfRotationPeriod = Config.laborSelfRotationPeriod
    @paintStrategy.selfRotationDirection = -1
    @paintStrategy.planetColor = Config.laborColor
    @paintStrategy.planetImg = @planetImg
    @paintStrategy.planetTexture = @planetTexture

  render: ->
    super =>
      @$el.html(@template(t: i18n.t))

