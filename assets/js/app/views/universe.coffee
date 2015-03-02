class MyUniverse.Views.Universe extends MyUniverse.Views.View
  template: JST['templates/universe']
  className: 'universe'

  # Static variables
  @totalObjects: 500
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
  # End static variables

  initialize: (opt = {})->
    @opt = opt

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
      
    # Set the paint strategy
    if opt.force2d
      @sceneStrategy = new Canvas2DUniverse(@$el, @imageLoader, @solarSystem)
    else
      @sceneStrategy = new WebGLUniverse(@$el, @imageLoader, @solarSystem)

    $(window).resize => @sceneStrategy.resize()
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
    @sceneStrategy.prepareScene(@objects, @constructor.totalObjects)
    $.when(@imageLoader, @solarSystem.imageLoaderPromise).done =>
      @sceneStrategy.paint()
      promise.resolve()
    promise    

class WebGLUniverse
  constructor: (@$domParent, @imageLoader, @solarSystem)->
    @scene = new THREE.Scene()
#    @camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 )
    @camera = new THREE.OrthographicCamera(window.innerWidth / - 2,
      window.innerWidth / 2,
      window.innerHeight / 2,  
      window.innerHeight / - 2, 0.1, 1000 )
    @camera.position.z = 10
    @renderer = new THREE.WebGLRenderer()
    
  prepareScene:(objects, totalObjects)->
    width = window.innerWidth + 50
    height = window.innerHeight + 50
    i = 0
    while i < totalObjects
      o = objects.sample()
      if o.maxCount?
        o.count ?= 0 # Private property
        continue if ++o.count > o.maxCount
      
      size = o.sizeInterval.sampleInterval()
      top = Math.random()   # Percentage
      left = Math.random()  # Percentage
      angle = o.rotateInterval.sampleInterval()

      texture = THREE.ImageUtils.loadTexture o.src
      material = new THREE.SpriteMaterial( map: texture, color: 0xffffff, fog: false )
      sprite = new THREE.Sprite( material )
      sprite.position.x = width * left - (width/2)
      sprite.position.y = height * top - (height/2)
      sprite.scale.x = sprite.scale.y = sprite.scale.z = size
      sprite.matrixAutoUpdate = false
      
      if o.opacityConfig == 'pulse'
        Animatable.makeAnimatable(material.color)
        material.color.animation
          transitions: [
            properties:
              r: 0
              g: 0
              b: 0
            duration: (1000 / o.pulseFrecuencyInterval.sampleInterval()) / 2
            initialTimeOffset: Math.random()
          ]
          count: 'infinite'
          alternateDirection: true
          queue: false
      else
        material.color.multiplyScalar(o.opacityConfig.sampleInterval())

      sprite.updateMatrix()
      @scene.add( sprite )
      ++i
    null
    
    # Call solarSystem.createObjects
    
  paint: ->
    @$domParent.append(@renderer.domElement)
    @resize() # For the first time
    @paintCanvas()

  resize: ->
    width = @$domParent.width()
    height = @$domParent.height()
    @camera.left = width / - 2
    @camera.right = width / 2
    @camera.top = height / 2
    @camera.bottom =  height / - 2
    @camera.updateProjectionMatrix()
    @renderer.setSize(width, height)
#    @paintCanvas(false)
    
  paintCanvas: (animate = true)->
    for o in @scene.children
      o.material.color.animate?()
    @renderer.render(@scene, @camera)
    requestAnimFrame(=> @paintCanvas()) if animate
  
class Canvas2DUniverse
  backgroundLastRenderTime: 0
  @backgroundFrameTime: 1000 / 15 # 1000 / (n frames per second)

  constructor: (@$domParent, @imageLoader, @solarSystem)->
  
  prepareScene: (objects, totalObjects)->
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