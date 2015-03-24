class SolarSystemWebGLPainter

  @sunTexture: 'assets/img/solarSystem/sun_texture3.png'


  constructor: (@sun, @planets, @opt={})->
    @sunRotationPeriod = Config.sunSelfRotationPeriod
    @sunSize = Config.sunSize * Config.wgSizeFactor
    @cameraInitialPosition = new THREE.Vector3(5000, 5000, 10000)

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

    # Set the initial camera position and rotation
    @camera.position.copy(@cameraInitialPosition)
    @camera.rotation.z =  Math.PI/10;
    @camera.up.applyEuler(@camera.rotation)

    @focusOnPlanet = null

    # Make the camera position and rotation "animatable"
    Animatable.makeAnimatable(@camera.position)
    Animatable.makeAnimatable(@camera.rotation)
    Animatable.makeAnimatable(@camera.up)


  onPaint: (elapsedTime)->
    planet.onPaint(elapsedTime) for _,planet of @planets
    @sun.rotation.animate()
    @camera.position.animate()
    @camera.rotation.animate()
    @camera.up.animate()

    if @focusOnPlanet
#      @camera.lookAt(@focusOnPlanet.paintStrategy.getPlanetRealPosition())
      if @focusFinished
        pos = @focusOnPlanet.paintStrategy.getPlanetRealPosition()
        @camera.position.x = pos.x
        @camera.position.z = pos.z + @focusOnPlanet.planetSize()*Config.wgSizeFactor*2


#    planetPos = @planets.personal.webGLGetPlanetRealPosition()
#    @camera.position.x = planetPos.x
#    @camera.position.y = planetPos.y + 8
#    @camera.position.z = planetPos.z + 15
#    @camera.lookAt(planetPos)

  addDebuggingObjects: ->
    axisHelper = new THREE.AxisHelper( 500 * Config.wgSizeFactor );
    @scene.add( axisHelper )

  goTo: (celestialObject, onEnd = $.noop)->
    duration = 5000
    yPos = 15
    @focusOnPlanet = null
    @focusFinished = false

    switch celestialObject
      when 'birdsEye'
        zPos = @sun.position.z + @sunSize*20
        xPos = @sun.position.x + 100
        yPos = 300
      when 'sun'
        zPos = @sun.position.z + @sunSize*2
        xPos = @sun.position.x
      else
        selectedPlanet = @planets[celestialObject]
        planetPainter = selectedPlanet.paintStrategy
        zPos = => planetPainter.getPlanetRealPosition().z + selectedPlanet.planetSize()*Config.wgSizeFactor*2
        xPos = => planetPainter.getPlanetRealPosition().x
        @focusOnPlanet = selectedPlanet


    @camera.position.transition
      properties:
        z: zPos
      duration: duration
      queue: false
      easing: Easing.easeInOut
    @camera.position.transition
      properties:
        x: xPos
      duration: duration
      queue: false
      easing: Easing.easeOut
      onEnd: =>
        @focusFinished = true
        onEnd()

    @camera.position.transition
      properties:
        y: @sunSize*2
      duration: duration/2
      queue: false
      easing: Easing.easeOut
    @camera.position.transition
      properties:
        y: yPos
      delay: duration/2
      duration: duration/2
      queue: false
      easing: Easing.easeInOut

    @camera.rotation.transition
      properties:
        x: =>
          startRotation = new THREE.Euler().copy(@camera.rotation)
          if planetPainter
            pos = planetPainter.getPlanetRealPosition()
          else
            pos = @sun.position
          @camera.lookAt(pos)
          endRotation = new THREE.Euler().copy( @camera.rotation )
          @camera.rotation.copy(startRotation)
          return endRotation.x
        y: =>
          startRotation = new THREE.Euler().copy(@camera.rotation)
          if planetPainter
            pos = planetPainter.getPlanetRealPosition()
          else
            pos = @sun.position
          @camera.lookAt(pos)
          endRotation = new THREE.Euler().copy( @camera.rotation )
          @camera.rotation.copy(startRotation)
          return endRotation.y
        z: =>
          startRotation = new THREE.Euler().copy(@camera.rotation)
          if planetPainter
            pos = planetPainter.getPlanetRealPosition()
          else
            pos = @sun.position
          @camera.lookAt(pos)
          endRotation = new THREE.Euler().copy( @camera.rotation )
          @camera.rotation.copy(startRotation)
          return endRotation.z
      duration: duration
      queue: false
      easing: Easing.easeInOut



