class MyUniverse.Views.Personal extends MyUniverse.Views.Planet
  template: JST['templates/planets/personal']
  className: 'personal'

  @planetImg = 'assets/img/solarSystem/planets/personal.png'

  initialize: ->
    super
    @planetSize = Config.planetSize
    @orbitRadius = Config.personalOrbitRadius
    @orbitPeriod = Config.personalOrbitPeriod
    @rotationAngle = Math.random() * 2 * Math.PI

    @imageLoader = new ImageLoader()
    @imageLoader.loadImages [@constructor.planetImg]

    Animatable.makeAnimatable(@)
    @animation
      transitions: [
        @transition
          properties:
            rotationAngle: 2 * Math.PI
          duration: @orbitPeriod
          easing: Easing.linear
        , false
      ]
      count: 'infinite'

  render: ->
    super =>
      @$el.html(@template())
      @

  paint: (ctx, cnv)->
    super
    @animate()
    ctx.save()

    ctx.rotate(@rotationAngle)
    ctx.translate(@orbitRadius, 0)
    ctx.drawImage(@imageLoader.images[@constructor.planetImg],
      -@planetSize/2, -@planetSize/2,
      @planetSize, @planetSize)

    ctx.restore()

