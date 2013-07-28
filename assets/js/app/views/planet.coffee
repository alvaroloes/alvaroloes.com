class MyUniverse.Views.Planet extends MyUniverse.Views.View

  initialize: ->
    @className = "planet #{@className}"
    @$el.addClass(@className)

    @planetSize = Config.planetSize
    @trailWidth = Config.trailWidth
    @initialRotationAngle = Math.random() * 2 * Math.PI
    @rotationAngle = @initialRotationAngle
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages [@planetImg]

    Animatable.makeAnimatable(@)
    @animation
      transitions: [
        @transition
          properties:
            rotationAngle: @initialRotationAngle + 2 * Math.PI
          duration: @orbitPeriod
          easing: Easing.linear
        , false
      ]
      count: 'infinite'

  render: (next = $.noop) ->
    next()

  updateProperties: ->
    @animate()

  paint: (ctx,cnv)->
    ctx.save()
    # Paint the trail
    ctx.beginPath()
    grad = ctx.createRadialGradient(0, 0, @orbitRadius - @trailWidth / 2, 0, 0, @orbitRadius + @trailWidth / 2)
    grad.addColorStop(0,@personalColor(0))
    grad.addColorStop(0.4,@personalColor(0.15))
    grad.addColorStop(0.6,@personalColor(0.15))
    grad.addColorStop(1,@personalColor(0))
    ctx.arc(0, 0, @orbitRadius, 0, 2*Math.PI, false)
    ctx.lineWidth = @trailWidth
    ctx.strokeStyle = grad
    ctx.stroke()

    ctx.rotate(@rotationAngle)
    ctx.translate(@orbitRadius, 0)

    ctx.drawImage(@imageLoader.images[@planetImg],
      -@planetSize/2, -@planetSize/2,
      @planetSize, @planetSize)

    ctx.restore()
