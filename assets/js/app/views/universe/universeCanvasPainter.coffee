class UniverseCanvasPainter
  backgroundLastRenderTime: 0
  @backgroundFrameTime: 1000 / 15 # 1000 / (n frames per second)

  constructor: (@$domParent, @imageLoader, @solarSystem)->

  prepareScene: (objects, totalObjects, forAnimating = true, forceOpacityTo)->
    @preparedObjects = []
    i = 0
    while i < totalObjects
      originalObject = objects.sample()
      if originalObject.maxCount?
        originalObject.count ?= 0 # Private property
        continue if ++originalObject.count > originalObject.maxCount
      o = $.extend({},originalObject)
      o.size = o.sizeInterval.sampleInterval()
      o.top = Math.random()   # Percentage
      o.left = Math.random()  # Percentage
      o.angle = o.rotateInterval.sampleInterval()
      o.opacityAnimationDuration = (1000 / o.pulseFrecuencyInterval.sampleInterval())

      if o.opacityConfig == 'pulse'
        if forAnimating
          Animatable.makeAnimatable(o)
          o.opacity = 0
          o.animation
            transitions: [
              properties:
                opacity: 1
              duration: o.opacityAnimationDuration
              initialTimeOffset: Math.random()
            ]
            count: 'infinite'
            alternateDirection: true
            queue: false
      else
        o.opacity = o.opacityInterval.sampleInterval()

      if forceOpacityTo != undefined
        o.opacity = forceOpacityTo;

      @preparedObjects.push(o)
      ++i
    @solarSystem?.prepareScene()
    null

  paint: ->
    bgCnv = document.createElement('canvas')
    @bgCtx = bgCnv.getContext('2d')
    cnv = document.createElement('canvas')
    @ctx = cnv.getContext('2d')
    @$domParent.append(bgCnv)
    @$domParent.append(cnv)
    @resize() # Resize for the first time
    @backgroundLastRenderTime = Date.now()
    @paintCanvas()

  resize: ->
    return unless @ctx
    @ctx.canvas.width = @bgCtx.canvas.width = @$domParent.width()
    @ctx.canvas.height = @bgCtx.canvas.height = @$domParent.height()
    @paintCanvas(false)

  paintCanvas: (animate = true)->
    @paintBackground(@bgCtx)
    @paintForeground(@ctx)
    requestAnimFrame(=> @paintCanvas()) if animate

  paintBackground: (ctx)->
    return if (Date.now() - @backgroundLastRenderTime) < @constructor.backgroundFrameTime

    @clear(ctx)
    for o in @preparedObjects
      ctx.save()
      o.animate?()
      ctx.globalAlpha = o.opacity
      ctx.translate(o.left * ctx.canvas.width + o.size / 2, o.top * ctx.canvas.height + o.size / 2)
      ctx.rotate(o.angle * Math.PI / 360)
      ctx.translate(-o.size / 2,-o.size / 2)
      ctx.drawImage(@imageLoader.images[o.src], 0, 0, o.size, o.size)
      #      ctx.fillStyle = '#00ffff';
      #      ctx.fillRect(0,0,o.size, o.size)
      ctx.restore()

    @backgroundLastRenderTime = Date.now()

  paintForeground: (ctx)->
    @clear(ctx)
    @solarSystem?.onPaint(ctx)

  clear: (ctx) ->
    # An ultra-optimized way to clear the canvas (instead of "clearRect")
    ctx.canvas.width = ctx.canvas.width
#    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height)