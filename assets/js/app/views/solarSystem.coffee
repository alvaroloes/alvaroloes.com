class MyUniverse.Views.SolarSystem extends MyUniverse.Views.View
  template: JST['templates/solarSystem']
  className: 'solarSystemWrap'

  @sunImg: 'assets/img/solarSystem/sun.png'

  initialize: ->
    @sunSize = Config.sunSize
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
    @imageLoader.loadImages [@constructor.sunImg]

    promises = [@imageLoader]
    promises.push planet.imageLoader for name,planet of @planets
    @imageLoaderPromise = $.when(promises)

    # Make solar system animatable
    Animatable.makeAnimatable(@)

  clickCanvas: (e)->
    where = if e.which == 2 then 'birdsEye' else null
    @goTo(where)

  # Render DOM stuff
  render: ->
    @

  # Paint canvas stuff
  paint: (ctx, cnv)->
    @animate()
    ctx.save()

    ctx.translate(cnv.width/2, cnv.height/2)
    ctx.scale(@solarSystemScale,@solarSystemScale)

    planet.updateProperties() for name,planet of @planets

    if @focusedPlanet and @centeringFinished
      @centerOffsetAngle  = @focusedPlanet.rotationAngle

    ctx.rotate(@centerOffsetAngle)
    ctx.translate(@centerOffset,0)
    ctx.rotate(-@centerOffsetAngle)

    ctx.drawImage(@imageLoader.images[@constructor.sunImg],
                  -@sunSize/2, -@sunSize/2,
                  @sunSize, @sunSize)

    planet.paint(ctx, cnv) for name,planet of @planets

    ctx.restore()

  goTo: (celestialObject = 'sun')->
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
            onEnd: => @centeringFinished = true

#    if celestialObject != 'birdsEye'
#      @transition
#        properties:
#          solarSystemScale: windowHeight / @sunSize
#          centerOffset: 0
#        duration: 3000
#        onEnd: => @centeringFinished = true


    @transition
      properties:
        solarSystemScale: windowHeight / objectHeight
        centerOffset: finalRadius
      duration: 3000


  setMovement: (move)->
    planet.setPauseState(!move) for name,planet of @planets
    @setPauseState(!move)


