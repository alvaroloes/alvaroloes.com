class MyUniverse.Views.Planet extends MyUniverse.Views.View
  tagName: "section"
  planetShadow: 'assets/img/solarSystem/planets/planet_shadow.png'
  initialize: ->
    @className = "planet #{@className}"
    @$el.addClass(@className)
    
    @planetRotationSpeed = 0.0001 # Radians per milliseconds

    @planetSize = Config.planetSize
    @trailWidth = Config.trailWidth
    @initialRotationAngle = Math.random() * 2 * Math.PI
    @rotationAngle = @initialRotationAngle
    @selfRotationAngle = 0
    @stopPaint = false
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages [@planetImg, @planetShadow]

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
    geo = new THREE.SphereGeometry(@planetSize * Config.webGLSizeFactor, 64, 64)
    material = new THREE.MeshPhongMaterial
      map: THREE.ImageUtils.loadTexture('assets/img/solarSystem/planets/textures/personal.jpg')
    @planet = new THREE.Mesh(geo, material)
    @planet.position.x = @orbitRadius * Config.webGLDistanceFactor
    @scene.add(@planet)
    
  render: (next = $.noop) ->
    next()
    @

  updateProperties:(elapsedTime)->
    @planet.rotation.y = elapsedTime * @planetRotationSpeed
    @animate()

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
