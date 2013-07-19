class MyUniverse.Views.SolarSystem extends MyUniverse.Views.View
  template: JST['templates/solarSystem']
  className: 'solarSystemWrap'

  @sunImg: 'assets/img/solarSystem/sun.svg'

  initialize: ->
    @sunSize = Config.sunSize

    # Create subviews
    @sun = new MyUniverse.Views.Sun()
    @planets =
      personal: new MyUniverse.Views.Personal()
#      reflexive: new MyUniverse.Views.Reflexive()
#      labor: new MyUniverse.Views.Labor()
#      technological: new MyUniverse.Views.Technological()

    # Preload images
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages [@constructor.sunImg]

    promises = [@imageLoader]
    promises.push planet.imageLoader for name,planet of @planets
    @imageLoaderPromise = $.when(promises)

    # Make solar system animatable
#    Animatable.makeAnimatable(@)
#    @animation
#      transitions: [
#        @transition
#          properties:
#            sunSize: 1000
#          duration: 1000
#        , false
#        @transition
#          properties:
#            sunSize: 100
#          duration: 2000
#        , false
#      ]
#      count: 'infinite'

  # Render DOM stuff
  render: ->
    @

  # Paint canvas stuff
  paint: (ctx, cnv)->
#    @animate()
    ctx.save()

    ctx.translate(cnv.width/2, cnv.height/2)
    ctx.drawImage(@imageLoader.images[@constructor.sunImg],
                  -@sunSize/2, -@sunSize/2,
                  @sunSize, @sunSize)
    planet.paint(ctx, cnv) for name,planet of @planets

    ctx.restore()

  goTo: (celestialObject = 'sun')->
    @$el.attr('goto',celestialObject)

  togglePlanetsAnimation: (animate)->
    @$el.find('.solarSystem')[unless animate then 'addClass' else 'removeClass']('stopPlanets')

