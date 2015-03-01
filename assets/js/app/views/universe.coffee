class MyUniverse.Views.Universe extends MyUniverse.Views.View
  template: JST['templates/universe']
  className: 'universe'

  backgroundLastRenderTime: 0
  # Static variables
  @totalObjects: 200
  @defaultObjectOpt:
    maxCount: null
    opacityConfig: 'pulse' #{'pulse',<interval>}
    pulseFrecuencyInterval: [0.1,0.3]
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
  @backgroundFrameTime: 1000 / 15 # 1000 / (n frames per second)
  # End static variables

  initialize: (opt = {})->
    @opt = opt
    $(window).resize => @resizeCanvas()

    # Initialize foreground elements
    @solarSystem = new MyUniverse.Views.SolarSystem()

    # Preload images
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages @constructor.pulseObjects.concat(@constructor.staticObjects)

    # Initialize background elements
    @objects = []
    @addObjects @constructor.pulseObjects

    props =
      maxCount: 1
      opacityConfig: [0.8,1]
      sizeInterval: [20,30]
    for o in @constructor.staticObjects
      @addObjects [$.extend({src: o},props)]

    null

  render: ->
    this.$el.html(@template())
    @$el.append(@solarSystem.render().el)
    @

  # This method returns a deferred object, so you must use paint().done(callback) to ensure
  # the first paint has finished (meaning that all images has been loaded from server and painted)
  paint: ->
    promise = $.Deferred()
    @lastPaintTime = Date.now()
    @prepareObjects()
    $.when(@imageLoader, @solarSystem.imageLoaderPromise).done =>
      @canvasPaintObjects()
      promise.resolve()
    promise


  addObjects: (objects)->
    for o in objects
      objData = o
      objData = {src: o} if $.type(o) is 'string'
      @objects.push $.extend({},@constructor.defaultObjectOpt,objData)
    null

  prepareObjects: ->
    @preparedObjects = []
    i = 0
    while i < @constructor.totalObjects
      originalObject = @objects.sample()
      if originalObject.maxCount?
        originalObject.count ?= 0 # Private property
        continue if ++originalObject.count > originalObject.maxCount
      o = $.extend({},originalObject)
      o.size = o.sizeInterval.sampleInterval()
      o.top = Math.random()   # Percentage
      o.left = Math.random()  # Percentage
      o.angle = o.rotateInterval.sampleInterval()

      if o.opacityConfig == 'pulse'
        Animatable.makeAnimatable(o)
        o.opacity = 0
        o.animation
          transitions: [
            properties:
              opacity: 1
            duration: (1000 / o.pulseFrecuencyInterval.sampleInterval()) / 2
            initialTimeOffset: Math.random()
          ]
          count: 'infinite'
          alternateDirection: true
          queue: false
      else
        o.opacity = o.opacityConfig.sampleInterval()

      @preparedObjects.push(o)
      ++i
    null

  ######## Canvas stuff #########

  canvasPaintObjects: ->
    bgCnv = document.createElement('canvas')
    @bgCtx = bgCnv.getContext('2d')
    cnv = document.createElement('canvas')
    @ctx = cnv.getContext('2d')
    @$el.append(bgCnv)
    @$el.append(cnv)
    @resizeCanvas() # Resize for the first time
    @paintCanvas()

  resizeCanvas: ->
    return unless @ctx
    @ctx.canvas.width = @bgCtx.canvas.width = @$el.width()
    @ctx.canvas.height = @bgCtx.canvas.height = @$el.height()
    @paintCanvas(false)

  paintCanvas: (animate = true)->
    @paintBackground()
    @paintForeground()

    requestAnimFrame(=> @paintCanvas()) if animate

  paintBackground: ->
    return if (Date.now() - @backgroundLastRenderTime) < @constructor.backgroundFrameTime

    @clear(@bgCtx)
    for o in @preparedObjects
      @bgCtx.save()
      o.animate() if o.opacityConfig == 'pulse'
      @bgCtx.globalAlpha = o.opacity
      @bgCtx.translate(o.left * @bgCtx.canvas.width, o.top * @bgCtx.canvas.height)
      @bgCtx.rotate(o.angle * Math.PI / 360)
      @bgCtx.drawImage(@imageLoader.images[o.src], 0, 0, o.size, o.size)
      @bgCtx.restore()

    @backgroundLastRenderTime = Date.now()

  paintForeground: ->
    @clear(@ctx)
    @solarSystem.paint(@ctx)

  clear: (ctx) ->
    # An ultra-optimized way to clear the canvas (instead of "clearRect")
    ctx.canvas.width = ctx.canvas.width
#    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height)


