class MyUniverse.Views.Universe extends MyUniverse.Views.View
#  template: JST['templates/universe']
  className: 'universe'
  @totalObjects: 350
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

  events:
    'mousedown canvas': 'clickCanvas'

  initialize: (opt = {})->
    @opt = opt
    $(window).resize => @resizeCanvas()

    # Make this a deferred object because it use ImageLoader, which is a deferred
    $.extend(this,$.Deferred())

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

  clickCanvas: (e)->
    @solarSystem.clickCanvas(e)

  # You must use this.done(callback) to ensure the render has finished
  render: ->
    $.when(@imageLoader, @solarSystem.imageLoaderPromise).done =>
      # DOM stuff
      @$el.html('')
      @$el.append(@solarSystem.render().el)

      # Canvas stuff
      @prepareObjects()
      @canvasPaintObjects()

      @resolve()
    @

  addObjects: (objects)->
    for o in objects
      objData = o
      objData = {src: o} if $.type(o) is 'string'
      @objects.push $.extend({},@constructor.defaultObjectOpt,objData)

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
      o.pulsePeriod = 1000 / o.pulseFrecuencyInterval.sampleInterval() # In milliseconds
      if o.opacityConfig == 'pulse'
        o.opacity = Math.random()
      else
        o.opacity = o.opacityConfig.sampleInterval()
      o.pulseTimeOffset = Math.random() * o.pulsePeriod

      @preparedObjects.push(o)
      ++i

#  domPaintObjects: ->
#    for o in @preparedObjects
#      $img = $('<img/>')
#        .attr(src: o.src)
#        .css(
#          top: "#{o.top * 100}%"
#          left: "#{o.left * 100}%"
#          width: o.size
#          height: o.size
#          transform: "rotate(#{o.angle}deg)"
#        )
#        .addClass('object')
#
#      if o.opacityConfig == 'pulse'
#        $img.css animationDuration: "#{o.pulsePeriod}ms"
#      else
#        $img.css
#          animation: 'none'
#          opacity: o.opacity
#
#      @$el.append($img)
#    null

  ######## Canvas stuff #########

  canvasPaintObjects: ->
    @cnv = document.createElement('canvas')
    @ctx = @cnv.getContext('2d')
    @$el.append(@cnv)
    @startTime = (new Date()).getTime()
    @resizeCanvas() # Resize for the first time
    @paintCanvas()

  resizeCanvas: ->
    return unless @cnv
    @cnv.width = @$el.width()
    @cnv.height = @$el.height()
    @paintCanvas(false)

  paintCanvas: (animate = true)->
    @ctx.clearRect(0, 0, @cnv.width, @cnv.height)
    time = (new Date()).getTime() - @startTime
    for o in @preparedObjects
      @ctx.save()
      if o.opacityConfig == 'pulse' # The opacity is animated with an oscilant function
        @ctx.globalAlpha = 0.5 * Math.sin((time + o.pulseTimeOffset) * 2 * Math.PI / o.pulsePeriod) + 0.5
      else
        @ctx.globalAlpha = o.opacity
      @ctx.translate(o.left * @cnv.width, o.top * @cnv.height)
      @ctx.rotate(o.angle * Math.PI / 360)
      @ctx.drawImage(@imageLoader.images[o.src], 0, 0, o.size, o.size)
      @ctx.restore()
    @solarSystem.paint(@ctx,@cnv)
    requestAnimFrame(=> @paintCanvas()) if animate

