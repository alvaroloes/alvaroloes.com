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
      @$el.html(@template
        t: i18n.t
        subsections: i18n.t('reflexive.subsections')
      )
      @$el.on('transitionend', (e)=> @sectionDidAppear(e))
    
  sectionDidAppear: (e)->
    return if e.target != @el
    event = e.originalEvent;
    if event.propertyName == 'opacity'
      if @$el.css('opacity') > 0
        @$el.children('nav').addClass('showNav')
      else
        @$el.children('nav').removeClass('showNav')
        
    @cylinder = new Cylinder(@$el.find('#cylinder'))


