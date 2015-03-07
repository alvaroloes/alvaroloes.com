class MyUniverse.Views.Universe extends MyUniverse.Views.View
  template: JST['templates/universe']
  className: 'universe'

  # Static variables
  @totalObjects: 500
  @defaultObjectOpt:
    maxCount: null
    opacityConfig: 'pulse' #{'pulse','static'}
    opacityInterval: [0.2,1]
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
      opacityConfig: 'static'
      opacityInterval: [0.8,1]
      sizeInterval: [20,30]
    for o in @constructor.staticObjects
      @addObjects [$.extend({src: o},props)]
      
    # Set the paint strategy
    if opt.force2d
      @sceneStrategy = new CanvasUniverse(@$el, @imageLoader, @solarSystem)
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
    $.when(@imageLoader, @solarSystem.imageLoaderPromise).done =>
#      @sceneStrategy.prepareScene(@objects, @constructor.totalObjects)
      @sceneStrategy.prepareOptimizedScene(@objects, @constructor.totalObjects)
      @sceneStrategy.paint()
      promise.resolve()
    promise    

class WebGLUniverse
  
  
  constructor: (@$domParent, @imageLoader, @solarSystem)->
    # Crete a canvas 2D universe only to draw the stars texture
    @canvasUniverse = new CanvasUniverse(@$domParent, @imageLoader, @solarSystem)
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 )
    @camera.position.z = 400
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize(window.innerWidth, window.innerHeight)
    
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
      material = new THREE.SpriteMaterial(map: texture)
      sprite = new THREE.Sprite( material )
      sprite.position.x = width * left - (width/2)
      sprite.position.y = height * top - (height/2)
      sprite.scale.x = sprite.scale.y = sprite.scale.z = size
      sprite.matrixAutoUpdate = false
      
      if o.opacityConfig == 'pulse'
        Animatable.makeAnimatable(material)
        material.animation
          transitions: [
            properties:
              opacity:0
            duration: (1000 / o.pulseFrecuencyInterval.sampleInterval()) / 2
            initialTimeOffset: Math.random()
          ]
          count: 'infinite'
          alternateDirection: true
          queue: false
      else
        material.opacity = o.opacityConfig.sampleInterval()

      sprite.updateMatrix()
      @scene.add( sprite )
      ++i
      
    @solarSystem.webGLPrepareScene(@scene,1)
    null
    
  prepareOptimizedScene: (objects, totalObjects)->
    #Create the background texture with the 2D canvas
    cnv = document.createElement('canvas')
    cnv.width = 2048
    cnv.height = 512
    ctx = cnv.getContext('2d')
    @canvasUniverse.prepareScene(objects, totalObjects, false, true)
    @canvasUniverse.paintBackground(ctx)

#    texture = new THREE.Texture(cnv)
#    texture.wrapS = THREE.RepeatWrapping;
#    texture.wrapT = THREE.RepeatWrapping;
#    texture.repeat.set( 2, 2);
#    texture.needsUpdate = true
#    material = new THREE.MeshBasicMaterial
#      map: texture
#      transparent: true
    geo = new THREE.PlaneGeometry(cnv.width*2,cnv.height*2,1,1)
    material = @getUniverseMaterial(ctx)
    plane = new THREE.Mesh(geo, material)
    
    @scene.add(plane)
    
  getUniverseMaterial: (ctx) ->
    # Create the texture
    texture = new THREE.Texture(ctx.canvas)
    texture.needsUpdate = true
    
    # Set up the positions and sizes of the painted obects to pass them as uniforms
    # to the shaders
    positions = []
    sizes = []
    animationTimes = []
    for o in @canvasUniverse.preparedObjects
      positions.push new THREE.Vector2(o.left, o.top)
      sizes.push new THREE.Vector2(o.size, o.size)
      animationTimes.push o.opacityAnimationDuration

    # Set all the uniforms
    uniforms =
      objectPosition: # Between 0 and 1
        type: 'v2v',
        value: positions
      objectSize:  # Between 0 and 1
        type: 'v2v',
        value: sizes
      objectAnimationTime:  # Between 0 and 1
        type: 'fv1',
        value: animationTimes
      texture:
        type: 't'
        value: texture
      textureWidth:
        type: 'i'
        value: ctx.canvas.with
      textureHeight:
        type: 'i'
        value: ctx.canvas.height

    # Set the constants to be passed to shaders
    defines = {
      NUM_OBJECTS: positions.length
    }

    
    material = new THREE.ShaderMaterial
      uniforms: uniforms
      defines: defines
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
        uniform vec2 objectPosition[NUM_OBJECTS];
        uniform vec2 objectSize[NUM_OBJECTS];
        uniform float objectAnimationTime[NUM_OBJECTS];
        uniform sampler2D texture;
        uniform int textureWidth;
        uniform int textureHeight;

        bool inside(vec2 squareTopLeft, vec2 squareBottomRight, vec2 pos) {
          return (pos.x >= squareTopLeft.x && pos.x <= squareBottomRight.x &&
                  pos.y >= squareTopLeft.y && pos.y <= squareBottomRight.y);
        }

        void main() {
          vec4 finalColor;
          for (int i = 0; i < 300; i++) {
            vec2 pos = objectPosition[i];
            vec2 size = objectSize[i];
// this is too slow
          }
          
          finalColor = texture2D(texture, iUV);



          gl_FragColor = finalColor;
        }
        '''
    material
    
    
  paint: ->
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
    for o in @scene.children
      o.material.animate?()
    @renderer.render(@scene, @camera)
    requestAnimFrame(=> @paintCanvas()) if animate
  
class CanvasUniverse
  backgroundLastRenderTime: 0
  @backgroundFrameTime: 1000 / 15 # 1000 / (n frames per second)

  constructor: (@$domParent, @imageLoader, @solarSystem)->
  
  prepareScene: (objects, totalObjects, forAnimating = true, ignoreOpacity = false)->
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
      
      if !ignoreOpacity
        if o.opacityConfig == 'pulse' && forAnimating
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
      ctx.translate(o.left * ctx.canvas.width, o.top * ctx.canvas.height)
      ctx.rotate(o.angle * Math.PI / 360)
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