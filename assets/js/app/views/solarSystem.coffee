class MyUniverse.Views.SolarSystem extends MyUniverse.Views.View
  template: JST['templates/solarSystem']
  className: 'solarSystemWrap'


  @images: [
    'assets/img/solarSystem/sun.png'
  ]

  initialize: ->
    @sunSize = 200
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

  # Render DOM stuff
  render: ->
#    @paint()
#      $cont = @$el.html(@template())
#                  .find('.solarSystem').append(@sun.render().el)
#      $cont.append(planet.render().el) for name, planet of @planets
    @

  # Paint canvas stuff
  paint: (cnv,ctx)->
    ctx.drawImage(@imageLoader.images['assets/img/solarSystem/sun.png'],
                  cnv.width/2 - @sunSize/2,
                  cnv.height/2 - @sunSize/2,
                  @sunSize, @sunSize)

  goTo: (celestialObject = 'sun')->
    @$el.attr('goto',celestialObject)

  togglePlanetsAnimation: (animate)->
    @$el.find('.solarSystem')[unless animate then 'addClass' else 'removeClass']('stopPlanets')


#  optimizeTrails: ->
#    for elem in @$el.children('.planetTrail')
#      @divideElem(elem,2,2)
#    undefined
#
#  divideElem: (div,rows, cols)->
#    $div = $(div)
#    # Make clones of the divs in its initial state (later will be filled with the chunks)
#    clonedDivs = ($div.clone() for i in [0...(rows*cols)])
#    squareW = $div.width() / cols
#    squareH = $div.height() / rows
#    halfCols = cols / 2
#    halfRows = rows / 2
#    i = -1
#    while ++i < rows
#      j = -1
#      while ++j < cols
#        $square = $('<div/>').addClass('planetTrailChunk').appendTo($div).css
#          top: (i - halfRows) * squareH
#          left: (j - halfCols) * squareW
#          width: squareW
#          height: squareH
#        $(clonedDivs.shift()).appendTo($square).css
#          top: -i * squareH
#          left: -j * squareW
#          margin: 0
#    $div.removeClass('planetTrail').css
#      width: 0
#      height: 0
#    undefined



