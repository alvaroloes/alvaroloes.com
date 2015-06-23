class MyUniverse.Views.SolarSystem extends MyUniverse.Views.View
  footerTemplate: JST['templates/footer']
  className: 'solarSystem'

  initialize: (@opt = {})->
    @sections = {}
    
    # Create subviews
    @sun = new MyUniverse.Views.Sun()
    @planets =
      personal: new MyUniverse.Views.Personal(@opt)
      reflexive: new MyUniverse.Views.Reflexive(@opt)
      labor: new MyUniverse.Views.Labor(@opt)
      tech: new MyUniverse.Views.Tech(@opt)
      
    # Choose the paint strategy
    if (@opt.force2d)
      @paintStrategy = new SolarSystemCanvasPainter(@sun, @planets, @opt)
    else
      @paintStrategy = new SolarSystemWebGLPainter(@sun, @planets, @opt)

  getImageLoaderPromise: ->
    @paintStrategy.getImageLoaderPromise()

  getNumberOfImagesToLoad: ->
    @paintStrategy.getNumberOfImagesToLoad()
    
  # Render DOM stuff
  render: ->
    @sections = {}

    # Render sun
    @sections.sun = @sun.render().$el
    @$el.html(@sections.sun)

    # Render all planets
    for name,planet of @planets
      @sections[name] = planet.render().$el
      @$el.append(@sections[name])

    # Render footer
    @$el.append(@footerTemplate())
    @
   
  # Paint stuff
  prepareScene: (args...)->
    @paintStrategy.prepareScene.apply(@paintStrategy,args)

  onPaint: (args...)->
    @paintStrategy.onPaint.apply(@paintStrategy,args)

  onResize: (args...)->
    @paintStrategy.onResize.apply(@paintStrategy,args)

  postProcessingPasses: ->
    @paintStrategy.postProcessingPasses?()

  extraComposer: ->
    @paintStrategy.extraComposer?()

  goTo: (celestialObject = 'birdsEye')->
    section.removeClass("show") for _, section of @sections
    @paintStrategy.goTo celestialObject, =>
      sectionToShow = @sections[celestialObject]
      section.removeClass("preshow") for name, section of @sections
      return unless sectionToShow?
      sectionToShow.addClass("preshow")
      reflow()
      sectionToShow.addClass("show")

