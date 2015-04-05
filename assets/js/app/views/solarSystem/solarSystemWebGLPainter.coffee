class SolarSystemWebGLPainter

  @sunTexture: 'assets/img/solarSystem/sun_texture.png'


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

    if @focusOnPlanet and @focusFinished
        pos = @focusOnPlanet.paintStrategy.getPlanetRealPosition()
        @camera.position.x = pos.x
        @camera.position.z = pos.z + @focusOnPlanet.planetSize()*Config.wgSizeFactor*2

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


    # Move the camera x, z coordinates to the to the celestial object
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

    # Now move the y coordinate with an up-down movement
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

    # Animate the target of the camera to point to the celestial object, taking into account
    # that it is moving, so the end position must be recalculated every frame
    # (The efficiency of the could be improved)
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

  postProcessingPasses: ->
#    shader = {
#
#      uniforms: {
#        "tDiffuse": { type: "t", value: null },
#        "amount":     { type: "f", value: 0.5 }
#      },
#
#      vertexShader: [
#
#        "varying vec2 vUv;",
#        "void main() {",
#        "vUv = uv;",
#        "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",
#
#        "}"
#
#      ].join("\n"),
#
#      fragmentShader: [
#
#        "uniform sampler2D tDiffuse;",
#        "uniform float amount;",
#        "varying vec2 vUv;",
#
#        "void main() {",
#
#        "vec4 color = texture2D(tDiffuse, vUv);",
#        "gl_FragColor = color*amount;",
#
#        "}"
#
#
#      ].join("\n")
#
#    };
    pass = new THREE.ShaderPass(THREE.RadialBlurShader)

    [pass]

