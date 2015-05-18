class UniverseWebGLPainter

  constructor: (@$domParent, @imageLoader, @solarSystem, @opt)->
    if (@opt.debug)
      @stats = new Stats()
      @stats.setMode(0)
      @stats.domElement.style.position = 'absolute'
      @stats.domElement.style.left = '0px'
      @stats.domElement.style.top = '0px'
      document.body.appendChild( @stats.domElement )
    # Crete a canvas 2D universe only to draw the stars texture
    @canvasUniverse = new UniverseCanvasPainter(@$domParent, @imageLoader, null)
    # Background scene, camera an renderer
    @bgScene = new THREE.Scene()
    @bgCamera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 100000 )
    @bgCamera.position.z = 450
    @bgRenderer = new THREE.WebGLRenderer()
    @bgRenderer.setSize(window.innerWidth, window.innerHeight)

    # Foreground scene camera an renderer
    @fgScene = new THREE.Scene()
    @fgCamera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 100000 )
    @fgRenderer = new THREE.WebGLRenderer(alpha: true)
    @fgRenderer.setClearColor(0x0, 0)
    @fgRenderer.setSize(window.innerWidth, window.innerHeight)

    # Postprocessing
    # We need to specify a render target with RGBA format to avoid loosing transparency
    parameters =
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      format: THREE.RGBAFormat
      stencilBuffer: false
    renderTarget = new THREE.WebGLRenderTarget( window.innerWidth, window.innerHeight, parameters );
    @composer = new THREE.EffectComposer(@fgRenderer, renderTarget)
    # Add the main render to the composer
    @composer.addPass(new THREE.RenderPass(@fgScene, @fgCamera))

  prepareScene: (objects, totalObjects)->
    #Create the background texture with the 2D canvas
    cnv = document.createElement('canvas')
    cnv.width = 2048
    cnv.height = 1024
    ctx = cnv.getContext('2d')
    @canvasUniverse.prepareScene(objects, totalObjects, false, 1)
    @canvasUniverse.paintBackground(ctx)

    geo = new THREE.PlaneBufferGeometry(cnv.width,cnv.height,1,1)
    material = @getUniverseMaterial(ctx)
    plane = new THREE.Mesh(geo, material)
    @bgScene.add(plane)

    @solarSystem.prepareScene(@fgScene,@fgCamera, @fgRenderer)

    # Add extra shader passes defined in the solar system
    passes = @solarSystem.postProcessingPasses()
    if passes?.length > 0
      @composer.addPass(pass) for pass in passes

    # Make an additive sum of the extra composer defined in solarSystem
    @solarSystemComposer = @solarSystem.extraComposer()
    if @solarSystemComposer?
      @additiveShader = new THREE.ShaderPass(THREE.AdditiveShader)
      @updateAdditiveShader()
      @composer.addPass(@additiveShader)

    # Add the final copy shader, that shows the final scene to the screen
    copyShader = new THREE.ShaderPass(THREE.CopyShader)
    copyShader.renderToScreen = true
    @composer.addPass(copyShader)

  updateAdditiveShader: ->
    if @solarSystemComposer? and @additiveShader?
      @additiveShader.uniforms.tAdd.value = @solarSystemComposer.renderTarget1

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
          #          textureAlpha = pixelData[index*4+3];
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

    # Finally create the material with the custom shaders
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

  paint: ->
    @startTime = Date.now();
    @$domParent.append(@bgRenderer.domElement)
    @$domParent.append(@fgRenderer.domElement)
    @resize() # For the first time
    @paintCanvas()

  resize: ->
    width = @$domParent.width()
    height = @$domParent.height()
    @bgCamera.aspect = width / height
    @bgCamera.updateProjectionMatrix()
    @bgRenderer.setSize(width, height)
    @fgCamera.aspect = width / height
    @fgCamera.updateProjectionMatrix()
    @fgRenderer.setSize(width, height)
    @composer?.setSize(width,height)
    @solarSystem.onResize?(width, height)
    @updateAdditiveShader()

  paintCanvas: (animate = true)->
    @stats?.begin()
    elapsedTime = Date.now() - @startTime
    @uniforms.elapsedTimeMillis.value = elapsedTime
    @solarSystem.onPaint(elapsedTime)
    @bgRenderer.render(@bgScene, @bgCamera)
    # The fgRenderer is managed by the composer
    @solarSystemComposer?.render()
    @composer.render()
    @stats?.end()
    requestAnimFrame(=> @paintCanvas()) if animate
