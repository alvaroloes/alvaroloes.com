class MyUniverse.Views.Planet extends MyUniverse.Views.View
  tagName: "section"
  planetShadow: 'assets/img/solarSystem/planets/planet_shadow.png'
  initialize: ->
    @className = "planet #{@className}"
    @$el.addClass(@className)
    
    # For WebGl all the speeds must be in radians per milliseconds
    # This properties will be overridden by the specific planets
    #    @wgPlanetRotationSpeed = 0.0005 # Radians per milliseconds
    #    @wgPlanetTranslationSpeed = -0.0001 # Radians per milliseconds

    @planetSize = Config.planetSize
    @trailWidth = Config.trailWidth
    @initialRotationAngle = Math.random() * 2 * Math.PI
    @rotationAngle = @initialRotationAngle
    @selfRotationAngle = 0
    @stopPaint = false
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages [@planetImg, @planetShadow, @planetTexture]

    Animatable.makeAnimatable(@)
    @animation
      transitions: [
        properties:
          rotationAngle: @initialRotationAngle + 2 * Math.PI
        duration: @orbitPeriod
        easing: Easing.linear
      ]
      count: 'infinite'
      queue: false
    @animation
      transitions: [
        properties:
          selfRotationAngle: 2 * Math.PI * @selfRotationDirection
        duration: @selfRotationPeriod
        easing: Easing.linear
      ]
      count: 'infinite'
      queue: false
  
  webGLPrepareScene: (@scene, @camera)->
    orbitRadius = @orbitRadius * Config.wgDistanceFactor
    planetSize = @planetSize * Config.wgSizeFactor
    # Create the pivot to rotate around and perform the planet translation
    @pivot = new THREE.Object3D()
    
    # Create the planet and add it to the pivot
    texture = new THREE.Texture(@imageLoader.images[@planetTexture])
    texture.needsUpdate = true
    geo = new THREE.SphereGeometry(planetSize, 64, 64)
    material = new THREE.MeshPhongMaterial
      map: texture
    @planet = new THREE.Mesh(geo, material)
    @planet.position.x = orbitRadius
    @pivot.add(@planet)
    @scene.add(@pivot)
    
    # Create the planet trail
    geo = new THREE.TorusGeometry(orbitRadius, planetSize*1.1, 32, 128)
    material = @getGlowMaterial()
    torus = new THREE.Mesh(geo, material)
    torus.rotation.x = Math.PI/2
    @scene.add(torus)
    
    # Animations: rotation and translation around sun
    Animatable.makeAnimatable(@planet.rotation)
    Animatable.makeAnimatable(@pivot.rotation)
    
    @planet.rotation.animation
      transitions: [
        properties:
          y: 2 * Math.PI * @selfRotationDirection
        duration: @selfRotationPeriod
        easing: Easing.linear
      ]
      count: 'infinite'
      queue: false
      
    @pivot.rotation.animation
      transitions: [
        properties:
          y: @initialRotationAngle + 2 * Math.PI
        duration: @orbitPeriod
        easing: Easing.linear
      ]
      count: 'infinite'
      queue: false
  
#    geo = new THREE.SphereGeometry(100, 64, 64);
#    material = @getGlowMaterial()
#    sphere = new THREE.Mesh(geo, material)
#    sphere.position.x = 150
#    @scene.add(sphere)

  getGlowMaterial: ->
    @uniforms =
      color: type: "c", value: new THREE.Color(0xffffff)

    material = new THREE.ShaderMaterial
      uniforms: @uniforms
      transparent: true
      vertexShader: '''
        varying vec3 iPosition;
        varying vec3 iNormal;
        void main() {
          iPosition = vec3(modelMatrix * vec4(position,1.0));
          iNormal = vec3(modelMatrix * vec4(normal,0.0));
          gl_Position = projectionMatrix *
                        modelViewMatrix *
                        vec4(position,1.0);
        }
        '''
      fragmentShader: '''
        uniform vec3 color;
        varying vec3 iPosition;
        varying vec3 iNormal;
        void main() {
          vec3 vectorToCamera = normalize(cameraPosition - iPosition);
          float alpha = pow(1.0 - abs(dot(iNormal, vectorToCamera)),2.0);
          gl_FragColor = vec4(color, alpha);
        }
        '''
    material.side = THREE.DoubleSide
    material
  
  webGLGetPlanetRealPosition: ->
    pos = new THREE.Vector3()
    @pivot.updateMatrixWorld()
    pos.setFromMatrixPosition(@planet.matrixWorld)
    pos
    
  render: (next = $.noop) ->
    next()
    @

  updateProperties:(elapsedTime)->
#    @planet.rotation.animate()
#    @pivot.rotation.animate()
#    @planet.rotation.y = elapsedTime * @wgPlanetRotationSpeed
#    @pivot.rotation.y = @initialRotationAngle + elapsedTime * @wgPlanetTranslationSpeed
#    @animate()

  paint: (ctx)->
    return if @stopPaint
    ctx.save()

    # Paint the trail
    ctx.beginPath()
    grad = ctx.createRadialGradient(0, 0, @orbitRadius - @trailWidth / 2, 0, 0, @orbitRadius + @trailWidth / 2)
    grad.addColorStop(0,@planetColor(0))
    grad.addColorStop(0.4,@planetColor(0.15))
    grad.addColorStop(0.6,@planetColor(0.15))
    grad.addColorStop(1,@planetColor(0))
    ctx.arc(0, 0, @orbitRadius, 0, 2*Math.PI, false)
    ctx.lineWidth = @trailWidth
    ctx.strokeStyle = grad
    ctx.stroke()

    ctx.rotate(@rotationAngle)
    ctx.translate(@orbitRadius, 0)

    ctx.save()
    ctx.rotate(@selfRotationAngle)
    # Draw the planet
    posXY = -@planetSize/2;
    ctx.drawImage(@imageLoader.images[@planetImg], posXY, posXY, @planetSize, @planetSize)
    ctx.restore()
    # Draw its shadow
    ctx.rotate(2 * Math.PI - Config.planetShadowAngle + Math.PI)
    ctx.drawImage(@imageLoader.images[@planetShadow], posXY, posXY, @planetSize, @planetSize)

    ctx.restore()
    null
