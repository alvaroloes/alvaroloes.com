class SolarSystemCanvasPainter

  @sunImg: 'assets/img/solarSystem/sun_medium.png'
  @sunHaloImg: 'assets/img/solarSystem/sunHalo_medium.png'

  constructor: (@sun, @planets, @opt={})->
    @sunSize = Config.sunSize
    @sunHaloSize = Config.sunSize*1.25
    @sunHaloAngle = 0
    @sunHaloAlpha = 1
    @solarSystemSize = Config.solarSystemSize
    @solarSystemScale = 1

    @focusedPlanet = null
    @centerOffset = 0
    @centerOffsetAngle = 0
    @centeringFinished = false

    # Preload images
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages [@constructor.sunImg, @constructor.sunHaloImg]
    @numImagesToLoad = @imageLoader.sources.length

    promises = [@imageLoader]
    for name,planet of @planets
      promises.push planet.getImageLoaderPromise()
      @numImagesToLoad += planet.getNumberOfImagesToLoad()
    @imageLoaderPromise = $.when.apply($,promises)

  getImageLoaderPromise: ->
    @imageLoaderPromise

  getNumberOfImagesToLoad: ->
    @numImagesToLoad

  setAnimations:->
    # Make solar system animatable
    Animatable.makeAnimatable(@)
    @animation
      transitions: [
        properties:
          sunHaloSize: @sunHaloSize*1.1
        duration: 4000
      ]
      count: 'infinite'
      alternateDirection: true
      queue: false
    @animation
      transitions: [
        properties:
          sunHaloAngle: 2*Math.PI
        duration: 100000
        easing: Easing.linear
      ]
      count: 'infinite'
      queue: false
    @animation
      transitions: [
        properties: sunHaloAlpha: 0.5
        duration: 5000
      ,
        properties: sunHaloAlpha: 0.8
        duration: 2000
      ,
        properties: sunHaloAlpha: 1
        duration: 1000
      ,
        properties: sunHaloAlpha: 0.5
        duration: 1000
      ,
        properties: sunHaloAlpha: 0
        duration: 3000
      ]
      count: 'infinite'
      alternateDirection: true
      queue: false

  prepareScene:->
    @setAnimations()
    planet.prepareScene() for _,planet of @planets

  onPaint: (ctx)->
    @animate()

    planet.onPaint(ctx, true) for name,planet of @planets

    ctx.save()
    # Set the (0,0) in the center and adjust the size of the solar system
    ctx.translate(ctx.canvas.width/2, ctx.canvas.height/2)
    ctx.scale(@solarSystemScale,@solarSystemScale)

    # Center the solar system in a planet if needed, taking into account if the animation
    # has finished
    if @focusedPlanet and @centeringFinished
      @centerOffsetAngle = @focusedPlanet.rotationAngle()

    ctx.rotate(@centerOffsetAngle)
    ctx.translate(@centerOffset,0)
    ctx.rotate(-@centerOffsetAngle)

    # Paint the sun halo
    ctx.save()
    ctx.rotate(@sunHaloAngle)
    ctx.globalAlpha = @sunHaloAlpha
    ctx.drawImage(@imageLoader.images[@constructor.sunHaloImg],
      -@sunHaloSize/2, -@sunHaloSize/2,
      @sunHaloSize, @sunHaloSize)
    ctx.restore()

    # Paint the sun
    ctx.drawImage(@imageLoader.images[@constructor.sunImg],
      -@sunSize/2, -@sunSize/2,
      @sunSize, @sunSize)

    #    # Paint all planets
    planet.onPaint(ctx) for name,planet of @planets

    ctx.restore()
    null

  goTo: (celestialObject = 'birdsEye', onEnd)->
    windowHeight = $(window).height()
    windowHeightInc = 400 # This makes planets overflow the window
    wasCenteredOnSun = !@focusedPlanet
    @centeringFinished = false
    @focusedPlanet = null
    finalRadius = 0
    finalAngle = 0

    switch celestialObject
      when 'birdsEye'
        objectHeight = @solarSystemSize
        @centeringFinished = true
        windowHeightInc = 0
      when 'sun'
        objectHeight = @sunSize
        @centeringFinished = true
      else
      # Focus on selected planet
        @focusedPlanet = @planets[celestialObject]
        finalRadius = -@focusedPlanet.orbitRadius()
        finalAngle = => @focusedPlanet.rotationAngle()
        objectHeight = @focusedPlanet.planetSize()

        if wasCenteredOnSun
          @centeringFinished = true
        else
          @transition
            properties:
              centerOffsetAngle: finalAngle
            duration: 2000
            queue: false
            onEnd: => @centeringFinished = true

    @transition
      properties:
        solarSystemScale: ( windowHeight + windowHeightInc ) / objectHeight
        centerOffset: finalRadius
      duration: 3000
      onEnd: onEnd

