class PlanetWebGLPainter

  constructor: ->
    @planetSize = Config.planetSize
    @initialRotationAngle = Math.random() * 2 * Math.PI

    #The following properties should be set by specific planets
    @orbitRadius = 0
    @orbitPeriod = 10000
    @selfRotationPeriod = 5000
    @selfRotationDirection = 1
    @planetColor = '#ffffff'
    @planetTexture = ''

  getImageLoaderPromise: ->
    @imageLoader = new ImageLoader()
    @imageLoader.loadImages [@planetTexture]

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
          y: @initialRotationAngle + 2 * Math.PI
        duration: @orbitPeriod
        easing: Easing.linear
      ]
      count: 'infinite'
      queue: false

  prepareScene:(@scene, @camera)->

    orbitRadius = @orbitRadius * Config.wgDistanceFactor
    planetSize = @planetSize * Config.wgSizeFactor
    # Create the pivot to rotate around and perform the planet translation
    @pivot = new THREE.Object3D()
    @pivot.rotation.y = @initialRotationAngle

    # Create the planet and add it to the pivot
    texture = new THREE.Texture(@imageLoader.images[@planetTexture])
    texture.needsUpdate = true
    geo = new THREE.SphereGeometry(planetSize, 64, 64)
    material = new THREE.MeshPhongMaterial
      map: texture
    @planet = new THREE.Mesh(geo, material)
    @planet.position.x = orbitRadius
    @pivot.add(@planet)
    @scene.add(@pivot)

    # Create the planet trail
    geo = new THREE.TorusGeometry(orbitRadius, planetSize*1.1, 32, 256)
    material = @getGlowMaterial()
    torus = new THREE.Mesh(geo, material)
    torus.rotation.x = Math.PI/2
    @scene.add(torus)

    @setAnimations()

  getGlowMaterial: ->
    @uniforms =
      color: type: "c", value: new THREE.Color(0xffffff)

    material = new THREE.ShaderMaterial
      uniforms: @uniforms
      transparent: true
      vertexShader: '''
        varying vec3 iPosition;
        varying vec3 iNormal;
        void main() {
          iPosition = vec3(modelMatrix * vec4(position,1.0));
          iNormal = vec3(modelMatrix * vec4(normal,0.0));
          gl_Position = projectionMatrix *
                        modelViewMatrix *
                        vec4(position,1.0);
        }
        '''
      fragmentShader: '''
        uniform vec3 color;
        varying vec3 iPosition;
        varying vec3 iNormal;
        void main() {
          vec3 vectorToCamera = normalize(cameraPosition - iPosition);
          float alpha = pow(1.0 - abs(dot(iNormal, vectorToCamera)),2.0);
          gl_FragColor = vec4(color, alpha);
        }
        '''
    material.side = THREE.BackSide
    material

  onPaint: ->
    @planet.rotation.animate()
    @pivot.rotation.animate()

  getPlanetRealPosition: ->
    pos = new THREE.Vector3()
    @pivot.updateMatrixWorld()
    pos.setFromMatrixPosition(@planet.matrixWorld)
    pos