class SolarSystemWebGLPainter

  @sunTexture: 'assets/img/solarSystem/sun_texture.jpg'

  godRaysLinearBlurValue: 2.5
  glowLinearBlurValue: 1
  lookAtPlanetFromYOffset: 10
  lookAtPlanetFromZSizeFactor: 1.5
  lookAtSunFromYOffset: 15
  lookAtSunFromZSizeFactor: 2

  pendingCameraAnimations: 0


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
#    if @opt.debug
#      @scene.add(new THREE.AxisHelper(300))

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

    @glowAdditiveUniform = {
      type: 'f'
      value: 1.7
    }
    Animatable.makeAnimatable(@glowAdditiveUniform)
    @glowAdditiveUniform.animation
      transitions: [
        properties:
          value: 2.5
        duration: 1000
        easing: Easing.easeInOut
      ]
      alternateDirection: true
      count: 'infinite'
      queue: false

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
    @glowAdditiveUniform.animate()

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

    @glowVerticalBlur.uniforms.v.value = @glowLinearBlurValue / @h
    @glowHorizontalBlur.uniforms.h.value = @glowLinearBlurValue / @w

    @glowComposer.render()

  onResize: (@w, @h)->
    @composer.setSize(w/2, h/2)
    @glowComposer.setSize(w/2, h/2)
    @verticalBlur.uniforms.v.value = @godRaysLinearBlurValue / h
    @horizontalBlur.uniforms.h.value = @godRaysLinearBlurValue / w
    @glowVerticalBlur.uniforms.v.value = @glowLinearBlurValue / h
    @glowHorizontalBlur.uniforms.h.value = @glowLinearBlurValue / w
    @updateAdditiveShader()

  goTo: (celestialObject, onEnd = $.noop)->
    @pendingCameraAnimations++
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
        if --@pendingCameraAnimations <= 0
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

    getRotationLookingAtTarget = =>
      startRotation = new THREE.Euler().copy(@camera.rotation)
      if planetPainter
        pos = planetPainter.getPlanetRealPosition()
      else
        pos = @sun.position
      @camera.lookAt(pos)
      endRotation = new THREE.Euler().copy( @camera.rotation )
      @camera.rotation.copy(startRotation)
      endRotation

    @camera.rotation.transition
      properties:
        x: => getRotationLookingAtTarget().x
        y: => getRotationLookingAtTarget().y
        z: => getRotationLookingAtTarget().z
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

    occlusionSceneRenderPass = new THREE.AltMaterialRenderPass('occlusionMaterial', @scene, @camera)

    @verticalBlur = new THREE.ShaderPass(THREE.VerticalBlurShader)
    @verticalBlur.uniforms.v.value = @godRaysLinearBlurValue / h
    @horizontalBlur = new THREE.ShaderPass(THREE.HorizontalBlurShader)
    @horizontalBlur.uniforms.h.value = @godRaysLinearBlurValue / w

    @radialBlur = new THREE.ShaderPass(THREE.RadialBlurShader)
    #Configure radial blur
    @radialBlur.uniforms.fExposure.value = 0.65
    @radialBlur.uniforms.fDecay.value = 0.92
    @radialBlur.uniforms.fDensity.value = 1
    @radialBlur.uniforms.fWeight.value = 0.25
    @radialBlur.uniforms.fClamp.value = 1

    passes = [
      occlusionSceneRenderPass
      @verticalBlur
      @horizontalBlur
      @radialBlur
      new THREE.ShaderPass(THREE.CopyShader)
    ]

    for pass in passes
      @composer.addPass(pass)

    @glowComposer = @getGlowComposer(w, h)
    @additiveShader = new THREE.ShaderPass(THREE.AdditiveShader)
    @additiveShader.uniforms.mixRatio = @glowAdditiveUniform
    @updateAdditiveShader()
    @composer.addPass(@additiveShader)

    if @opt.debug
      gui = new dat.GUI()
      gui.add(@radialBlur.uniforms.fExposure, 'value').min(0.0).max(2.0).step(0.01).name("Exposure")
      gui.add(@radialBlur.uniforms.fDecay, 'value').min(0.6).max(2.0).step(0.01).name("Decay")
      gui.add(@radialBlur.uniforms.fDensity, 'value').min(0.0).max(2.0).step(0.01).name("Density")
      gui.add(@radialBlur.uniforms.fWeight, 'value').min(0.0).max(2.0).step(0.01).name("Weight")
      gui.add(@radialBlur.uniforms.fClamp, 'value').min(0.0).max(2.0).step(0.01).name("Clamp")
      gui.add({value: @godRaysLinearBlurValue}, 'value').min(0.0).max(5.0).step(0.01).name("Blur").onChange (val)=>
        @verticalBlur.uniforms.v.value = val / h
        @horizontalBlur.uniforms.h.value = val / w

    @composer

  getGlowComposer: (w, h)->
    parameters =
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      format: THREE.RGBAFormat
      stencilBuffer: false
    renderTarget = new THREE.WebGLRenderTarget( w/2, h/2, parameters );
    composer = new THREE.EffectComposer(@renderer, renderTarget)

    blurSceneRenderPass = new THREE.AltMaterialRenderPass('glowMaterial', @scene, @camera)
    @glowVerticalBlur = new THREE.ShaderPass(THREE.VerticalBlurShader)
    @glowVerticalBlur.uniforms.v.value = @glowLinearBlurValue / h
    @glowHorizontalBlur = new THREE.ShaderPass(THREE.HorizontalBlurShader)
    @glowHorizontalBlur.uniforms.h.value = @glowLinearBlurValue / w

    passes = [
      blurSceneRenderPass
      @glowHorizontalBlur
      @glowVerticalBlur
      new THREE.ShaderPass(THREE.CopyShader)
      ]

    for pass in passes
      composer.addPass(pass)
    composer

  updateAdditiveShader: ->
    @additiveShader.uniforms.tAdd.value = @glowComposer.renderTarget1



