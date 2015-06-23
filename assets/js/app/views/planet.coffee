class MyUniverse.Views.Planet extends MyUniverse.Views.View
  tagName: "section"
  
  initialize: (@opt)->
    @className = "planet #{@className}"
    @$el.addClass(@className)
    
    if (@opt.force2d)
      @paintStrategy = new PlanetCanvasPainter()
    else
      @paintStrategy = new PlanetWebGLPainter()
    
  render: (next = $.noop) ->
    next()
    @

  getImageLoaderPromise: ->
    @paintStrategy.getImageLoaderPromise()

  getNumberOfImagesToLoad: ->
    @paintStrategy.getNumberOfImagesToLoad()

  # Paint stuff
  prepareScene: (args...)->
    @paintStrategy.prepareScene.apply(@paintStrategy,args)

  onPaint: (args...)->
    @paintStrategy.onPaint.apply(@paintStrategy,args)

  orbitRadius:->
     @paintStrategy.orbitRadius
  rotationAngle:->
     @paintStrategy.rotationAngle
  planetSize:->
     @paintStrategy.planetSize

