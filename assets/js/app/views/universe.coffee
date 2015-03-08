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

  initialize: (opt = {})->
    @opt = opt
    @opt.debug = true

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
      opacityConfig: 'static'
      pulseFrecuencyInterval: [0,0]
      opacityInterval: [0.8,1]
      sizeInterval: [20,30]
    for o in @constructor.staticObjects
      @addObjects [$.extend({src: o},props)]
      
    # Set the paint strategy
    if opt.force2d
      @sceneStrategy = new CanvasUniverse(@$el, @imageLoader, @solarSystem, @opt)
    else
      @sceneStrategy = new WebGLUniverse(@$el, @imageLoader, @solarSystem, @opt)

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
    $.when(@imageLoader, @solarSystem.imageLoaderPromise).done =>
      @sceneStrategy.prepareScene(@objects, @constructor.totalObjects)
      @sceneStrategy.paint()
      promise.resolve()
    promise    

class WebGLUniverse
  
  
  constructor: (@$domParent, @imageLoader, @solarSystem, @opt)->
    # Crete a canvas 2D universe only to draw the stars texture
    @canvasUniverse = new CanvasUniverse(@$domParent, @imageLoader, @solarSystem)
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 )
    @camera.position.z = 450
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize(window.innerWidth, window.innerHeight)
        
  prepareScene: (objects, totalObjects)->
    @addDebuggingObjects() if @opt.debug
    
    #Create the background texture with the 2D canvas
    cnv = document.createElement('canvas')
    cnv.width = 2048
    cnv.height = 1024
    ctx = cnv.getContext('2d')
    @canvasUniverse.prepareScene(objects, totalObjects, false, 1)
    @canvasUniverse.paintBackground(ctx)
    
    geo = new THREE.PlaneGeometry(cnv.width,cnv.height,1,1)
    material = @getUniverseMaterial(ctx)
    plane = new THREE.Mesh(geo, material)
    @scene.add(plane)
    @solarSystem.webGLPrepareScene(@scene,1)
    
  getUniverseMaterial: (ctx) ->
    # Create the texture with the generated canvas
    texture = new THREE.Texture(ctx.canvas)
    texture.needsUpdate = true
    
    # Create a map with the opacity frequency for each pixel
    
    w = ctx.canvas.width
    h = ctx.canvas.height
    pixelData = ctx.getImageData(0, 0, w, h).data
    totalPixels = w*h
    opacityFrequency = new Uint8Array(totalPixels)
    
    # Initialize the opacity frequencies to 0
    opacityFrequency[i] = 0 for i in [0...opacityFrequency.length] by 1
    
    for o in @canvasUniverse.preparedObjects
      # Calculate the bounding square of each object and get its opacity frequency
      top = Math.round(o.top * h)
      left = Math.round(o.left * w)
      bottom = Math.round(top + o.size)
      right = Math.round(left + o.size)
      objectOpacityFrequency = o.pulseFrecuencyInterval.sampleInterval() * 255;
      
      # Traverse the square and set each pixel with the opacity frequency
      for j in [top...bottom] by 1
        for i in [left...right] by 1
          index = i + j*w
          # textureAlpha = pixelData[index*4+3];
          continue if index < 0 or index >= totalPixels
          opacityFrequency[index] = objectOpacityFrequency

    opacityFrequencyAlphaMap = new THREE.DataTexture(opacityFrequency, w, h, THREE.AlphaFormat)
    opacityFrequencyAlphaMap.needsUpdate = true

    # Set all the uniforms for the material fragment shader
    @uniforms =
      elapsedTimeMillis:
        type: 'f'
        value: 0
      texture:
        type: 't'
        value: texture
      opacityFrequencyAlphaMap:
        type: 't'
        value: opacityFrequencyAlphaMap

    material = new THREE.ShaderMaterial
      uniforms: @uniforms
      transparent: true
      vertexShader: '''
        varying vec2 iUV;
        void main() {
          iUV = uv;
          gl_Position = projectionMatrix *
                        modelViewMatrix *
                        vec4(position,1.0);
        }
        '''
      fragmentShader: '''
        varying vec2 iUV;
        uniform float elapsedTimeMillis;
        uniform sampler2D texture;
        uniform sampler2D opacityFrequencyAlphaMap;

        void main() {
          float opacityFrequency = texture2D(opacityFrequencyAlphaMap, iUV).a / 1000.;
          vec4 finalColor = texture2D(texture, iUV);
          finalColor.a *= (1. + cos(opacityFrequency*elapsedTimeMillis)) / 2.;
          gl_FragColor = finalColor;
        }
        '''
    material
    
  addDebuggingObjects: ->
    axisHelper = new THREE.AxisHelper( 100 );
    @scene.add( axisHelper )
    
  paint: ->
    @startTime = Date.now();
    @$domParent.append(@renderer.domElement)
    @resize() # For the first time
    @paintCanvas()

  resize: ->
    width = @$domParent.width()
    height = @$domParent.height()
    @camera.aspect = width / height
    @camera.updateProjectionMatrix()
    @renderer.setSize(width, height)
    
  paintCanvas: (animate = true)->
#    for o in @scene.children
#      o.material.animate?()
    @uniforms.elapsedTimeMillis.value = Date.now() - @startTime;
    @renderer.render(@scene, @camera)
    requestAnimFrame(=> @paintCanvas()) if animate
  
class CanvasUniverse
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
      o.opacityAnimationDuration = (1000 / o.pulseFrecuencyInterval.sampleInterval()) / 2
      
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
    @solarSystem.paint(ctx)

  clear: (ctx) ->
    # An ultra-optimized way to clear the canvas (instead of "clearRect")
    ctx.canvas.width = ctx.canvas.width
#    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height)