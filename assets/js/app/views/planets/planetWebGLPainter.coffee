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
    @parent.add(@pivot)

    # Create the planet trail
    geo = new THREE.TorusGeometry(orbitRadius, planetSize*0.7, 32, 1024)
    material = @getTrailMaterial(orbitRadius, planetSize, @pivot.rotation.y)
    torus = new THREE.Mesh(geo, material)
    torus.rotation.x = -Math.PI/2
    torus.occlusionMaterial = torus.glowMaterial = new THREE.MeshBasicMaterial
      color: 0x000000
      transparent: true
      opacity: 0
    @parent.add(torus)

    @scene.add(@parent)

    @setAnimations()

  getTrailMaterial: (orbitRadius, planetRadius, planetYTranslationAngle, color = 0xffffff)->
    @trailMaterialUniforms =
      color: type: "c", value: new THREE.Color(color)
      orbitRadius: type: "f", value: orbitRadius
      planetYTranslationAngle: type:"f", value: planetYTranslationAngle
      planetRadius: type:"f", value: planetRadius
      time: type: "f", value: 0

    material = new THREE.ShaderMaterial
      uniforms: @trailMaterialUniforms
      transparent: true
      vertexShader: '''
        uniform float orbitRadius;
        uniform float planetYTranslationAngle;
        uniform float planetRadius;
        uniform float time;
        varying vec3 iPosition;
        varying vec3 iNormal;
        #define PI 3.1415926535897932384626433832795
        #define TWO_PI 2.0*PI

        float easeInOut(float t) {
          return 3.0*(1.0-t)*t*t + t*t*t;
        }

        vec3 calculateNewPosition(float anglesOffset, float tolerance) {
          if (anglesOffset > tolerance ) {
            return position;
          }

          vec3 newPosition;
          float distanceRatio = anglesOffset/tolerance;
          float distanceModifier = easeInOut(1.0 - distanceRatio);
          float waveModifier = 0.5*(1.0-distanceRatio)*sin(25.0*(distanceRatio - time/1000.0));
          newPosition = position + normal * planetRadius*0.5 * distanceModifier + waveModifier;

          return newPosition;
        }

        void main() {

          //--> Modify the position if it is near the planet position

          //Calculate the angle of the current position
          float positionZAngle = acos(dot(normalize(position), vec3(1,0,0)));
          if (position.y < 0.0) {
            positionZAngle = TWO_PI - positionZAngle;
          }

          //Make the planet angle to be between 0 and 360 and always positive
          float planetAngle = mod(planetYTranslationAngle,TWO_PI);
          if (planetAngle < 0.0) {
            planetAngle += TWO_PI;
          }

          //Calculate the offset between the two angles, taking care of the limits (360 and 0)
          float anglesOffset = abs(mod(positionZAngle - planetAngle + PI, TWO_PI) - PI);

          //Positions inside the tolerance will be modified
          float tolerance = 5.0*planetRadius / orbitRadius;

          //Finally calculate the new position
          vec3 newPosition = calculateNewPosition(anglesOffset, tolerance);

          //Interpolated position for fragment shader
          iPosition = vec3(modelMatrix * vec4(newPosition,1.0));
          //Interpolated normal for fragment shader
          iNormal = vec3(modelMatrix * vec4(normal,0.0));

          gl_Position = projectionMatrix *
                        modelViewMatrix *
                        vec4(newPosition,1.0);
        }
        '''
      fragmentShader: '''
        uniform vec3 color;
        varying vec3 iPosition;
        varying vec3 iNormal;
        void main() {
          //The more facing to camera the more transparent
          vec3 vectorToCamera = cameraPosition - iPosition;
          float alpha = pow(1.0 - abs(dot(iNormal, normalize(vectorToCamera))),2.0);

          //If the camera is too close, make it transparent
          float min = 25.0;
          float range = 100.0;
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
    @trailMaterialUniforms.planetYTranslationAngle.value = @pivot.rotation.y
    @trailMaterialUniforms.time.value = elapsedTime

  getPlanetRealPosition: ->
    pos = new THREE.Vector3()
    @pivot.updateMatrixWorld()
    pos.setFromMatrixPosition(@planet.matrixWorld)
    pos