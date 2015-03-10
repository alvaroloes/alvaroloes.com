class MyUniverse.Views.Labor extends MyUniverse.Views.Planet
  template: JST['templates/planets/labor']
  className: 'labor'
  planetImg: 'assets/img/solarSystem/planets/labor.png'

  initialize: ->
    @wgPlanetRotationSpeed = 2*Math.PI / Config.laborSelfRotationPeriod
    @wgPlanetTranslationSpeed = 2*Math.PI / Config.laborOrbitPeriod
    @orbitRadius = Config.laborOrbitRadius
    @orbitPeriod = Config.laborOrbitPeriod
    @selfRotationPeriod = Config.laborSelfRotationPeriod
    @selfRotationDirection = -1
    @planetColor = Config.laborColor
    super

  render: ->
    super =>
      @$el.html(@template(t: i18n.t))

