class MyUniverse.Views.Labor extends MyUniverse.Views.Planet
  template: JST['templates/planets/labor']
  className: 'labor'
  planetImg: 'assets/img/solarSystem/planets/labor.png'
  planetTexture: 'assets/img/solarSystem/planets/textures/labor.jpg'

  initialize: ->
    @orbitRadius = Config.laborOrbitRadius
    @orbitPeriod = Config.laborOrbitPeriod
    @selfRotationPeriod = Config.laborSelfRotationPeriod
    @selfRotationDirection = -1
    @planetColor = Config.laborColor
    super

  render: ->
    super =>
      @$el.html(@template(t: i18n.t))

