class MyUniverse.Views.SolarSystem extends MyUniverse.Views.View
  template: JST['templates/solarSystem']
  className: 'solarSystemWrap'

  @sunImg: 'assets/img/solarSystem/sun.png'

  initialize: ->
    @sunSize = Config.sunSize
    @solarSystemSize = Config.solarSystemSize
    @solarSystemScale = 1

    # Create subviews
    @sun = new MyUniverse.Views.Sun()
    @planets =
      personal: new MyUniverse.Views.Personal()
      reflexive: new MyUniverse.Views.Reflexive()
      labor: new MyUniverse.Views.Labor()
      technological: new MyUniverse.Views.Technological()

    # Preload images
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages [@constructor.sunImg]

    promises = [@imageLoader]
    promises.push planet.imageLoader for name,planet of @planets
    @imageLoaderPromise = $.when(promises)

    # Make solar system animatable
    Animatable.makeAnimatable(@)

  clickCanvas: (e)->
    where = if e.which == 2 then 'birdsEye' else null
    @goTo(where)

  # Render DOM stuff
  render: ->
    @

  # Paint canvas stuff
  paint: (ctx, cnv)->
    @animate()
    ctx.save()

    ctx.translate(cnv.width/2, cnv.height/2)
    ctx.scale(@solarSystemScale,@solarSystemScale)
    ctx.drawImage(@imageLoader.images[@constructor.sunImg],
                  -@sunSize/2, -@sunSize/2,
                  @sunSize, @sunSize)
    planet.paint(ctx, cnv) for name,planet of @planets

    ctx.restore()

  goTo: (celestialObject = 'sun')->
    windowHeight = $(window).height()
    switch celestialObject
      when 'birdsEye'
        @transition
          properties: solarSystemScale: windowHeight / @solarSystemSize
          duration: 5000
          queue: false
      when 'sun'
        @transition
          properties: solarSystemScale: windowHeight / @sunSize
          duration: 5000
          queue: false

  setMovement: (move)->
    @setPauseState(!move)

  togglePlanetsAnimation: (animate)->
    @$el.find('.solarSystem')[unless animate then 'addClass' else 'removeClass']('stopPlanets')

