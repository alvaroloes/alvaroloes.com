class MyUniverse.Views.Reflexive extends MyUniverse.Views.Planet
  template: JST['templates/planets/reflexive']
  className: 'reflexive'
  planetImg: 'assets/img/solarSystem/planets/reflexive.png'

  initialize: ->
    @orbitRadius = Config.reflexiveOrbitRadius
    @orbitPeriod = Config.reflexiveOrbitPeriod
    @selfRotationPeriod = Config.laborSelfRotationPeriod
    @selfRotationDirection = -1
    @planetColor = Config.reflexiveColor
    super

  render: ->
    super =>
      @$el.html(@template())

  paint: (ctx, cnv)->
    super

