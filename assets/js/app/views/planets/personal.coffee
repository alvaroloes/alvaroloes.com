class MyUniverse.Views.Personal extends MyUniverse.Views.Planet
  template: JST['templates/planets/personal']
  className: 'personal'
  planetImg: 'assets/img/solarSystem/planets/personal.png'
  planetTexture: 'assets/img/solarSystem/planets/textures/personal.jpg'
  articles: {}

  initialize: (@opt)->
    super
    @paintStrategy.orbitRadius = Config.personalOrbitRadius
    @paintStrategy.orbitPeriod = Config.personalOrbitPeriod
    @paintStrategy.selfRotationPeriod = Config.personalSelfRotationPeriod
    @paintStrategy.selfRotationDirection = -1
    @paintStrategy.planetColor = Config.personalColor
    @paintStrategy.planetImg = @planetImg
    @paintStrategy.planetTexture = @planetTexture

  render: ->
    super =>
      @$el.html(@template
        t: i18n.t
        articles: i18n.t("personal.articles")
      )

