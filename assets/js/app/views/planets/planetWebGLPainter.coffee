class PlanetWebGLPainter

  constructor: ->
    @planetSize = Config.planetSize
    @initialRotationAngle = Math.random() * 2 * Math.PI

    #The following properties should be set by specific planets
    @orbitRadius = 0
    @orbitPeriod = 10000
    @orbitDirection = 1
    @orbitDeflection = 0
    @selfRotationPeriod = 5000
    @selfRotationDirection = 1
    @selfRotationDeflection = 0
    @planetColor = '#ffffff'
    @planetTexture = ''
    @bumpMap = null
    @glowMap = null

  getImageLoaderPromise: ->
    @imageLoader = new ImageLoader()
    imgs = [@planetTexture]
    if @bumpMap?
      imgs.push @bumpMap
    if @glowMap?
      imgs.push @glowMap
    @imageLoader.loadImages imgs

  setAnimations: ->
    # Animations: rotation and translation around sun
    Animatable.makeAnimatable(@planet.rotation)
    Animatable.makeAnimatable(@pivot.rotation)

    @planet.rotation.animation
      transitions: [
        properties:
          y: 2 * Math.PI * @selfRotationDirection
        duration: @selfRotationPeriod
        easing: Easing.linear
      ]
      count: 'infinite'
      queue: false

    @pivot.rotation.animation
      transitions: [
        properties:
          y: @initialRotationAngle + 2 * Math.PI * @orbitDirection
        duration: @orbitPeriod
        easing: Easing.linear
      ]
      count: 'infinite'
      queue: false

  prepareScene:(@scene, @camera)->

    orbitRadius = @orbitRadius * Config.wgDistanceFactor
    planetSize = @planetSize * Config.wgSizeFactor

    # Create a parent object to insert the planet pivot and the torus to allow deflected orbits
    @parent = new THREE.Object3D()
    @parent.rotation.z = @orbitDeflection

    # Create the pivot to rotate around and perform the planet translation
    @pivot = new THREE.Object3D()
    @pivot.rotation.y = @initialRotationAngle
    
    # Create the planet and add it to the pivot
    texture = new THREE.Texture(@imageLoader.images[@planetTexture])
    texture.needsUpdate = true
    geo = new THREE.SphereGeometry(planetSize, 64, 64)
    material = new THREE.MeshPhongMaterial
      map: texture

    if @bumpMap?
      material.bumpMap = new THREE.Texture(@imageLoader.images[@bumpMap])
      material.bumpMap.needsUpdate = true
      material.bumpScale = 0.5

    @planet = new THREE.Mesh(geo, material)
    @planet.position.x = orbitRadius
    @planet.rotation.order = "XZY"
    @planet.rotation.z = @selfRotationDeflection

    if @glowMap?
      glowTexture = new THREE.Texture(@imageLoader.images[@glowMap])
      glowTexture.needsUpdate = true
      @planet.glowMaterial = new THREE.MeshBasicMaterial
        map: glowTexture
    @pivot.add(@planet)


    # Create the planet trail. We compose it with two arcs, one of them animated
    torusColor = 0xffffff
    torusWidth = planetSize*1.1
    torusTransparentMaterial = new THREE.MeshBasicMaterial
      color: 0x000000
      transparent: true
      opacity: 0
    animatedTrailRatio = 5
    animatedArcAngle = -@orbitDirection*animatedTrailRatio*planetSize/orbitRadius

    geo = new THREE.TorusGeometry(orbitRadius, torusWidth, 32, 24, animatedArcAngle)
    material = @getTrailMaterial(true, animatedArcAngle, torusColor)
    animatedTorusArc = new THREE.Mesh(geo, material)
    animatedTorusArc.rotation.x = -Math.PI/2
    animatedTorusArc.occlusionMaterial = torusTransparentMaterial
    animatedTorusArc.glowMaterial = torusTransparentMaterial
    @pivot.add(animatedTorusArc)

    geo = new THREE.TorusGeometry(orbitRadius,torusWidth, 32, 256, -@orbitDirection*2*Math.PI - animatedArcAngle)
    material = @getTrailMaterial(false, 0, torusColor)
    fixedTorusArc = new THREE.Mesh(geo, material)
    fixedTorusArc.rotation.x = -Math.PI/2
    fixedTorusArc.rotation.z = animatedArcAngle
    fixedTorusArc.occlusionMaterial = torusTransparentMaterial
    fixedTorusArc.glowMaterial = torusTransparentMaterial
    @pivot.add(fixedTorusArc)

    @parent.add(@pivot)
    @scene.add(@parent)

    @setAnimations()

  getTrailMaterial: (withWavyBehavior, wavySizeRadians, color = 0xffffff)->
    uniforms =
      color: type: "c", value: new THREE.Color(color)
      wavySizeRadians: type:"f", value: wavySizeRadians

    wavyCode = ''
    if withWavyBehavior
      @wavyTimeUniform =
        type: "f",
        value: 0
      uniforms.time = @wavyTimeUniform
      wavyCode = '''
          //--> Modify the position to create a wavy effect if it is near the planet position
          //Calculate the angle of the current position
          float positionZAngle = acos(dot(normalize(position), vec3(1,0,0)));

          //Finally calculate the new position
          newPosition = calculateNewPosition(positionZAngle);
      '''

    material = new THREE.ShaderMaterial
      uniforms: uniforms
      transparent: true
      vertexShader: """
        uniform float wavySizeRadians;
        uniform float time;
        varying vec3 iPosition;
        varying vec3 iNormal;
        #define PI 3.14159265359
        #define TWO_PI 2.0*PI

        float easeInOut(float t) {
          return 3.0*(1.0-t)*t*t + t*t*t;
        }

        vec3 calculateNewPosition(float angleOffset) {
          float distanceRatio = abs(angleOffset/wavySizeRadians);
          float waveModifier =  easeInOut(distanceRatio)*2.0*(1.0-distanceRatio)*sin(25.0*(distanceRatio - time/1000.0));
          return  position + waveModifier;
        }

        void main() {
          vec3 newPosition = position;
          #{wavyCode}
          //Interpolated position for fragment shader
          iPosition = vec3(modelMatrix * vec4(newPosition,1.0));
          //Interpolated normal for fragment shader
          iNormal = vec3(modelMatrix * vec4(normal,0.0));

          gl_Position = projectionMatrix *
                        modelViewMatrix *
                        vec4(newPosition,1.0);
        }
        """
      fragmentShader: '''
        uniform vec3 color;
        varying vec3 iPosition;
        varying vec3 iNormal;
        void main() {
          //The more facing to camera the more transparent
          vec3 vectorToCamera = cameraPosition - iPosition;
          float alpha = pow(1.0 - abs(dot(iNormal, normalize(vectorToCamera))),2.0);

          //If the camera is too close, make it transparent
          float min = 35.0;
          float range = 125.0;
          float distanceToCamera = length(vectorToCamera);
          float distanceModifier = max(0.0,(distanceToCamera-min)/range);
          if (distanceModifier < 1.0)
          {
            alpha *= distanceModifier;
          }

          gl_FragColor = vec4(color, alpha);
        }
        '''
    material.side = THREE.BackSide
    material.depthWrite = false
    material

  onPaint: (elapsedTime)->
    @planet.rotation.animate()
    @pivot.rotation.animate()
    @wavyTimeUniform.value = elapsedTime

  getPlanetRealPosition: ->
    pos = new THREE.Vector3()
    @pivot.updateMatrixWorld()
    pos.setFromMatrixPosition(@planet.matrixWorld)
    pos