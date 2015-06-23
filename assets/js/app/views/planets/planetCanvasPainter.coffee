class PlanetCanvasPainter

  planetShadow: 'assets/img/solarSystem/planets/planet_shadow.png'

  constructor: ->
    @planetSize = Config.planetSize
    @trailWidth = Config.trailWidth
    @initialRotationAngle = Math.random() * 2 * Math.PI
    @rotationAngle = @initialRotationAngle
    @selfRotationAngle = 0

    #The following properties should be set by the specific planets
    @orbitRadius = 0
    @orbitPeriod = 10000
    @selfRotationPeriod = 5000
    @selfRotationDirection = 1
    @planetColor = '#ffffff'
    @planetImg = ''

  getImageLoaderPromise: ->
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages [@planetImg, @planetShadow]
    @imageLoader

  setAnimations: ->
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

  prepareScene: ->
    @setAnimations()

  onPaint: (ctx, onlyUpdateProperties = false)->
    @animate()
    return if onlyUpdateProperties

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

