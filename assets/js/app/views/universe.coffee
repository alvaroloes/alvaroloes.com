class MyUniverse.Views.Universe extends MyUniverse.Views.View
  template: JST['templates/universe']
  className: 'universe'

  # Static variables
  @totalObjects: 1000
  @defaultObjectOpt:
    maxCount: null
    opacityConfig: 'pulse' #{'pulse','static'}
    opacityInterval: [0.2,1]
    pulseFrecuencyInterval: [0.3,1]
    sizeInterval: [3,12] # In pixels
    rotateInterval: [0,360]
    
  @pulseObjects: [
    'assets/img/universe/estrella4puntas.png'
    'assets/img/universe/estrella5puntas.png'
    'assets/img/universe/estrella6puntas.png'
  ]
  @staticObjects: [
    'assets/img/universe/galaxia1.png'
    'assets/img/universe/galaxia2.png'
    'assets/img/universe/galaxia3.png'
    'assets/img/universe/galaxia4.png'
    'assets/img/universe/galaxia5.png'
    'assets/img/universe/blackHole.png'
    'assets/img/universe/eyeNebula.png'
    'assets/img/universe/rareObject.png'
  ]
  # End static variables

  initialize: (@opt = {})->
#    @opt.force2d = true
    @opt.debug = true

    # Initialize foreground elements
    @solarSystem = new MyUniverse.Views.SolarSystem(@opt)

    # Preload images
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages @constructor.pulseObjects.concat(@constructor.staticObjects)

    # Initialize background elements
    @objects = []
    @addObjects @constructor.pulseObjects

    props =
      maxCount: 1
      opacityConfig: 'static'
      pulseFrecuencyInterval: [0,0]
      opacityInterval: [0.8,1]
      sizeInterval: [20,30]
    for o in @constructor.staticObjects
      @addObjects [$.extend({src: o},props)]
      
    # Choose the paint strategy
    if @opt.force2d
      @paintStrategy = new UniverseCanvasPainter(@$el, @imageLoader, @solarSystem, @opt)
    else
      @paintStrategy = new UniverseWebGLPainter(@$el, @imageLoader, @solarSystem, @opt)

    $(window).resize => @paintStrategy.resize()
    null

  addObjects: (objects)->
    for o in objects
      objData = o
      objData = {src: o} if $.type(o) is 'string'
      @objects.push $.extend({},@constructor.defaultObjectOpt,objData)
    null

  render: ->
    this.$el.html(@template())
    @$el.append(@solarSystem.render().el)
    @

  # This method returns a deferred object, so you must use paint().done(callback) to ensure
  # the first paint has finished (meaning that all images has been loaded from server and painted)
  paint: ->
    promise = $.Deferred()
    $.when(@imageLoader, @solarSystem.getImageLoaderPromise()).done =>
      @paintStrategy.prepareScene(@objects, @constructor.totalObjects)
      @paintStrategy.paint()
      promise.resolve()
    promise