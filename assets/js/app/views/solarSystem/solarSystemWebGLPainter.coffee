class SolarSystemWebGLPainter

  @sunTexture: 'assets/img/solarSystem/sun_texture.jpg'

  linearBlurValue: 2.5
  lookAtPlanetFromYOffset: 10
  lookAtSunFromYOffset: 15
  lookAtPlanetFromZSizeFactor: 1.5
  lookAtSunFromZSizeFactor: 2


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


  prepareScene: (@scene, @camera, @renderer)->
    # Sun
    texture = new THREE.Texture(@imageLoader.images[@constructor.sunTexture])
    texture.needsUpdate = true
    geo = new THREE.SphereGeometry(@sunSize, 64, 64)
    material = new THREE.MeshBasicMaterial
        map: texture
    @sun = new THREE.Mesh(geo, material)
    @sun.occlusionMaterial = material
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

    @radialBlurCenter = new THREE.Vector3()

  onPaint: (elapsedTime)->
    planet.onPaint(elapsedTime) for _,planet of @planets
    @sun.rotation.animate()
    @camera.position.animate()
    @camera.rotation.animate()
    @camera.up.animate()

    if @focusOnPlanet and @focusFinished
      pos = @focusOnPlanet.paintStrategy.getPlanetRealPosition()
      @camera.position.x = pos.x
      @camera.position.y = pos.y + @lookAtPlanetFromYOffset
      @camera.position.z = pos.z + @focusOnPlanet.planetSize()*Config.wgSizeFactor*@lookAtPlanetFromZSizeFactor

    # Update the radial blur center to be the sun position
    @sun.updateMatrixWorld()
    @radialBlurCenter.setFromMatrixPosition(@sun.matrixWorld).project(@camera)
    # The radial blur shader uniforms expect the center of the screen to be (0.5,0.5)
    # while "project()" assumes it is (0,0). Normalize this
    @radialBlurCenter.x = (@radialBlurCenter.x + 1) / 2
    @radialBlurCenter.y = (@radialBlurCenter.y + 1) / 2

    @radialBlur.uniforms.fX.value = @radialBlurCenter.x
    @radialBlur.uniforms.fY.value = @radialBlurCenter.y

  onResize: (w, h)->
    @composer.setSize(w/2, h/2)
    @verticalBlur.uniforms.v.value = @linearBlurValue / h
    @horizontalBlur.uniforms.h.value = @linearBlurValue / w

  goTo: (celestialObject, onEnd = $.noop)->
    duration = Config.changePlanetAnimationDuration
    @focusOnPlanet = null
    @focusFinished = false

    switch celestialObject
      when 'birdsEye'
        zPos = @sun.position.z + @sunSize*20
        xPos = @sun.position.x + 100
        yPos = 300
      when 'sun'
        xPos = @sun.position.x
        yPos = @sun.position.y + @lookAtSunFromYOffset
        zPos = @sun.position.z + @sunSize*@lookAtSunFromZSizeFactor
      else
        selectedPlanet = @planets[celestialObject]
        planetPainter = selectedPlanet.paintStrategy
        xPos = => planetPainter.getPlanetRealPosition().x
        yPos = => planetPainter.getPlanetRealPosition().y + @lookAtPlanetFromYOffset
        zPos = => planetPainter.getPlanetRealPosition().z + selectedPlanet.planetSize()*Config.wgSizeFactor*@lookAtPlanetFromZSizeFactor
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
    #TODO: This should not be applied in the initial transition
    # 1.- Change the
    # Animation
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

  extraComposer: ->
    # Use postprocessing to get a "god rays" effect.
    # This is a combination of radial blur plus linear blur over the occlusion scene
    # then add the result to the base scene
    parameters =
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      format: THREE.RGBAFormat
      stencilBuffer: false
    w = window.innerWidth
    h = window.innerHeight
    renderTarget = new THREE.WebGLRenderTarget( w/2, h/2, parameters );
    @composer = new THREE.EffectComposer(@renderer, renderTarget)

    occlusionSceneRenderPass = new THREE.OcclusionRenderPass(@scene, @camera)

    @radialBlur = new THREE.ShaderPass(THREE.RadialBlurShader)
    @verticalBlur = new THREE.ShaderPass(THREE.VerticalBlurShader)
    @verticalBlur.uniforms.v.value = @linearBlurValue / h
    @horizontalBlur = new THREE.ShaderPass(THREE.HorizontalBlurShader)
    @horizontalBlur.uniforms.h.value = @linearBlurValue / w

    passes = [
      occlusionSceneRenderPass
      @verticalBlur
      @horizontalBlur
      @radialBlur]

    for pass in passes
      @composer.addPass(pass)

    #Configure radial blur
    @radialBlur.uniforms.fExposure.value = 0.65
    @radialBlur.uniforms.fDecay.value = 0.92
    @radialBlur.uniforms.fDensity.value = 1
    @radialBlur.uniforms.fWeight.value = 0.25
    @radialBlur.uniforms.fClamp.value = 1

    if @opt.debug
      gui = new dat.GUI()
      gui.add(@radialBlur.uniforms.fExposure, 'value').min(0.0).max(2.0).step(0.01).name("Exposure")
      gui.add(@radialBlur.uniforms.fDecay, 'value').min(0.6).max(2.0).step(0.01).name("Decay")
      gui.add(@radialBlur.uniforms.fDensity, 'value').min(0.0).max(2.0).step(0.01).name("Density")
      gui.add(@radialBlur.uniforms.fWeight, 'value').min(0.0).max(2.0).step(0.01).name("Weight")
      gui.add(@radialBlur.uniforms.fClamp, 'value').min(0.0).max(2.0).step(0.01).name("Clamp")
      gui.add({value: @linearBlurValue}, 'value').min(0.0).max(5.0).step(0.01).name("Blur").onChange (val)=>
        @verticalBlur.uniforms.v.value = val / h
        @horizontalBlur.uniforms.h.value = val / w

    @composer



