class MyUniverse.Views.Personal extends MyUniverse.Views.Planet
  template: JST['templates/planets/personal']
  className: 'personal'
  planetImg: 'assets/img/solarSystem/planets/personal.png'
  articles: {}

  initialize: ->
    @orbitRadius = Config.personalOrbitRadius
    @orbitPeriod = Config.personalOrbitPeriod
    @selfRotationPeriod = Config.personalSelfRotationPeriod
    @selfRotationDirection = -1
    @planetColor = Config.personalColor
    super

  render: ->
    super =>
      @$el.html(@template
        t: i18n.t
        articles: i18n.t("personal.articles")
      )

  paint: (ctx, cnv)->
    super

