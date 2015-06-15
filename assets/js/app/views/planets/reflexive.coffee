class MyUniverse.Views.Reflexive extends MyUniverse.Views.Planet
  template: JST['templates/planets/reflexive']
  className: 'reflexive'
  planetImg: 'assets/img/solarSystem/planets/reflexive.png'
  planetTexture: 'assets/img/solarSystem/planets/textures/reflexive.jpg'

  initialize: (@opt)->
    super
    @paintStrategy.orbitRadius = Config.reflexiveOrbitRadius
    @paintStrategy.orbitPeriod = Config.reflexiveOrbitPeriod
    @paintStrategy.orbitDirection = -1
    @paintStrategy.orbitDeflection = Math.PI/20
    @paintStrategy.selfRotationPeriod = Config.laborSelfRotationPeriod
    @paintStrategy.selfRotationDirection = 1
    @paintStrategy.planetColor = Config.reflexiveColor
    @paintStrategy.planetImg = @planetImg
    @paintStrategy.planetTexture = @planetTexture

  render: ->
    super =>
      @$el.html(@template
        t: i18n.t
      )
      @quoteSlider = new QuotesSlider @$el.find('#quotesSlider')
#      ,  shuffle: true
      @$el.on('transitionend', (e)=> @sectionDidAppear(e))

    
  sectionDidAppear: (e)->
    return if e.target != @el
    @quoteSlider.play()
    event = e.originalEvent;
    if event.propertyName == 'opacity'
      if @$el.css('opacity') > 0
        @$el.children('nav').addClass('showNav')
      else
        @$el.children('nav').removeClass('showNav')



