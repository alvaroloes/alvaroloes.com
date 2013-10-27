class MyUniverse.Views.Personal extends MyUniverse.Views.Planet
  template: JST['templates/planets/personal']
  className: 'personal'
  planetImg: 'assets/img/solarSystem/planets/personal.png'

  initialize: ->
    @orbitRadius = Config.personalOrbitRadius
    @orbitPeriod = Config.personalOrbitPeriod
    @selfRotationPeriod = Config.personalSelfRotationPeriod
    @selfRotationDirection = -1
    @personalColor = Config.personalColor
    super

  render: ->
    super =>
      @$el.html(@template())
      @

  paint: (ctx, cnv)->
    super

