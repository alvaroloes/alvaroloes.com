class MyUniverse.Views.SolarSystem extends MyUniverse.Views.View
  template: JST['templates/solarSystem']
  className: 'solarSystemWrap'

  @sunImg: 'assets/img/solarSystem/sun.png'
  @sunHaloImg: 'assets/img/solarSystem/sunHalo.png'

  initialize: ->
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

    # Create subviews
    @sun = new MyUniverse.Views.Sun()
    @planets =
      personal: new MyUniverse.Views.Personal()
      reflexive: new MyUniverse.Views.Reflexive()
      labor: new MyUniverse.Views.Labor()
      technological: new MyUniverse.Views.Technological()

    # Preload images
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages [@constructor.sunImg, @constructor.sunHaloImg]

    promises = [@imageLoader]
    promises.push planet.imageLoader for name,planet of @planets
    @imageLoaderPromise = $.when(promises)

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

  # Render DOM stuff
  render: ->
    this.$el.html(@template())
    @

  # Paint canvas stuff
  paint: (ctx, cnv)->
    @animate()
    ctx.save()
    # Set the (0,0) in the center and adjust the size of the solar sitem
    ctx.translate(cnv.width/2, cnv.height/2)
    ctx.scale(@solarSystemScale,@solarSystemScale)

    # Update all planet properties for animation
    planet.updateProperties() for name,planet of @planets

    # Center the solar system in a planet if needed, taking into account if the animation
    # has finished
    if @focusedPlanet and @centeringFinished
      @centerOffsetAngle  = @focusedPlanet.rotationAngle

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

    # Paint all planets
    planet.paint(ctx, cnv) for name,planet of @planets

    ctx.restore()

  goTo: (celestialObject = 'birdsEye')->
    windowHeight = $(window).height()
    wasCenteredOnSun = !@focusedPlanet
    @centeringFinished = false
    @focusedPlanet = null
    finalRadius = 0
    finalAngle = 0

    switch celestialObject
      when 'birdsEye'
        objectHeight = @solarSystemSize
        @centeringFinished = true
      when 'sun'
        objectHeight = @sunSize
        @centeringFinished = true
      else
        # Focus on selected planet
        @focusedPlanet = @planets[celestialObject]
        finalRadius = -@focusedPlanet.orbitRadius
        finalAngle = => @focusedPlanet.rotationAngle
        objectHeight = @focusedPlanet.planetSize
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
        solarSystemScale: windowHeight / ( objectHeight - 0.3 * objectHeight )
        centerOffset: finalRadius
      duration: 3000



  setMovement: (move)->
    planet.setPauseState(!move) for name,planet of @planets
    @setPauseState(!move)


