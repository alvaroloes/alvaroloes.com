class MyUniverse.Views.Tech extends MyUniverse.Views.Planet
  template: JST['templates/planets/tech']
  className: 'tech'
  planetImg: 'assets/img/solarSystem/planets/tech.png'

  initialize: ->
    @wgPlanetRotationSpeed = 2*Math.PI / Config.laborSelfRotationPeriod
    @wgPlanetTranslationSpeed = 2*Math.PI / Config.laborOrbitPeriod
    @orbitRadius = Config.techOrbitRadius
    @orbitPeriod = Config.techOrbitPeriod
    @selfRotationPeriod = Config.techSelfRotationPeriod
    @selfRotationDirection = -1
    @planetColor = Config.techColor
    super

  render: ->
    super =>
      @$el.html(@template(t: i18n.t))

