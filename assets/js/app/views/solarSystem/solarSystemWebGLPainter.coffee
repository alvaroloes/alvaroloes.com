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