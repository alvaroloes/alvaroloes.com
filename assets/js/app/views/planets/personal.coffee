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

#    t = i18n.t;
#    @articles[t("personal.whoAmI")] = t('personal.whoAmI_text')
#    @articles[t("personal.myHobbies")] = t('personal.myHobbies_text')
#    @articles[t("personal.myGoals")] = t('personal.myGoals_text')
#    @articles[t("personal.contact")] = t('personal.contact_text')
    super

  render: ->
    super =>
      @$el.html(@template
        t:i18n.t
        articles: i18n.t("personal.articles")
      )

  paint: (ctx, cnv)->
    super

