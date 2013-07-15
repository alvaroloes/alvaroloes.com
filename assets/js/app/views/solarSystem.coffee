class MyUniverse.Views.SolarSystem extends MyUniverse.Views.View
  template: JST['templates/solarSystem']
  className: 'solarSystemWrap'

  @images: [
    'assets/img/solarSystem/sun.png'
  ]


  initialize: ->
    @sunSize = 20
    # Preload images
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages @constructor.images

    # Create subviews
    @sun = new MyUniverse.Views.Sun()
    @planets =
      personal: new MyUniverse.Views.Personal()
      reflexive: new MyUniverse.Views.Reflexive()
      labor: new MyUniverse.Views.Labor()
      technological: new MyUniverse.Views.Technological()

    # Make solar system animatable
    Animatable.makeAnimatable(@)
    @animation
      transitions: [
        @transition
          properties:
            sunSize: 1000
          duration: 1000
        , false
        @transition
          properties:
            sunSize: 100
          duration: 2000
        , false
      ]
      count: 'infinite'

  # Render DOM stuff
  render: ->
    @

  # Paint canvas stuff
  paint: (cnv,ctx)->
    @animate()
    ctx.drawImage(@imageLoader.images['assets/img/solarSystem/sun.png'],
                  cnv.width/2 - @sunSize/2,
                  cnv.height/2 - @sunSize/2,
                  @sunSize, @sunSize)

  goTo: (celestialObject = 'sun')->
    @$el.attr('goto',celestialObject)

  togglePlanetsAnimation: (animate)->
    @$el.find('.solarSystem')[unless animate then 'addClass' else 'removeClass']('stopPlanets')

