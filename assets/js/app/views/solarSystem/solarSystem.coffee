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
    @paintStrategy.imageLoader
    
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

  goTo: (celestialObject = 'birdsEye')->
    section.removeClass("show") for _, section of @sections
    @paintStrategy.goTo celestialObject, =>
      sectionToShow = @sections[celestialObject]
      section.removeClass("preshow") for name, section of @sections
      return unless sectionToShow?
      sectionToShow.addClass("preshow")
      reflow()
      sectionToShow.addClass("show")

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

    promises = [@imageLoader]
    promises.push planet.getImageLoaderPromise() for name,planet of @planets
    @imageLoaderPromise = $.when(promises)
  
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

  
class SolarSystemWebGLPainter
  
  @sunTexture: 'assets/img/solarSystem/sun_texture3.png'
  
  constructor: (@sun, @planets, @opt={})->
    @sunRotationPeriod = Config.sunSelfRotationPeriod
    @sunSize = Config.sunSize * Config.wgSizeFactor
    
    # Preload textures
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages [@constructor.sunTexture]

    promises = [@imageLoader]
    promises.push planet.getImageLoaderPromise() for name,planet of @planets
    @imageLoaderPromise = $.when(promises)

  prepareScene: (@scene, @camera)->
    @addDebuggingObjects() if @opt.debug

    # Sun
    texture = new THREE.Texture(@imageLoader.images[@constructor.sunTexture])
    texture.needsUpdate = true
    geo = new THREE.SphereGeometry(@sunSize, 64, 64)
    material = new THREE.MeshBasicMaterial
      map: texture
    @sun = new THREE.Mesh(geo, material)
    @scene.add(@sun)

    # Ambient light
    @scene.add(new THREE.AmbientLight( 0x404040))

    # Sun light
    sunLight = new THREE.PointLight( 0xffffaa, 3, Config.wgDistanceFactor * 6 )
    sunLight.position.set( 0, 0, 0 )
    @scene.add(sunLight)

    # Add planets to scene
    planet.prepareScene(@scene, @camera) for _,planet of @planets

    # Sun animation
    Animatable.makeAnimatable(@sun.rotation)
    @sun.rotation.animation
      transitions: [
        properties:
          y: 2 * Math.PI
        duration: @sunRotationPeriod
        easing: Easing.linear
      ]
      count: 'infinite'
      queue: false


    # Testing:
    @camera.position.z = 4000
    @camera.position.x = 0
    @camera.position.y = 500

    Animatable.makeAnimatable(@camera.position)
    Animatable.makeAnimatable(@camera.rotation)

    #    @camera.position.animation
    #      transitions: [
    #        properties:
    #          y: -50
    #        duration: 6000
    #      ]
    #      count: 'infinite'
    #      alternateDirection: true
    #      queue: false
    #    @camera.position.animation
    #      transitions: [
    #        properties:
    #          x: -300
    #        duration: 6000
    #      ]
    #      count: 'infinite'
    #      alternateDirection: true
    #      queue: false

    @camera.position.transition
      properties:
        z: 200
      duration: 10000
      queue: false
      easing: Easing.easeOut
    @camera.position.transition
      properties:
        y: 100
      duration: 10000
      queue: false
      easing: Easing.linear
    @camera.rotation.transition
      properties:
        z: Math.PI/8
      duration: 10000
      queue: false
      easing: Easing.easeInOut



  onPaint: (elapsedTime)->
    planet.onPaint(elapsedTime) for _,planet of @planets
    @sun.rotation.animate()
    @camera.position.animate()
    @camera.rotation.animate()
#    @camera.lookAt(@sun.position)

#    planetPos = @planets.personal.webGLGetPlanetRealPosition()
#    @camera.position.x = planetPos.x
#    @camera.position.y = planetPos.y + 8
#    @camera.position.z = planetPos.z + 15
#    @camera.lookAt(planetPos)


  addDebuggingObjects: ->
    axisHelper = new THREE.AxisHelper( 500 * Config.wgSizeFactor );
    @scene.add( axisHelper )