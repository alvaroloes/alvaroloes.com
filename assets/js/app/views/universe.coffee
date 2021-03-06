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

  totalLightYears: 100000


  initialize: (@opt = {})->
#    @opt.force2d = true
    @opt.debug = false

    # Initialize foreground elements
    @solarSystem = new MyUniverse.Views.SolarSystem(@opt)

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
      
    # Choose the paint strategy
    if @opt.force2d
      @paintStrategy = new UniverseCanvasPainter(@$el, @imageLoader, @solarSystem, @opt)
    else
      @paintStrategy = new UniverseWebGLPainter(@$el, @imageLoader, @solarSystem, @opt)

    $(window).resize => @paintStrategy.resize()

    # Wrap all image loaders promises together to keep track of the loading process
    @promiseAllImages = $.when(@imageLoader, @solarSystem.getImageLoaderPromise())

    totalImages = @imageLoader.sources.length + @solarSystem.getNumberOfImagesToLoad()
    @loadTracker = new LoadTracker totalImages + 1, # + 1 To track the creation of the stars
      onStep: (percentage)=> @onLoadingStep(percentage)
      onComplete: => @onLoadingComplete()

    @promiseAllImages.progress @loadTracker.stepper()

    @lastLightYears = @totalLightYears
    null

  addObjects: (objects)->
    for o in objects
      objData = o
      objData = {src: o} if $.type(o) is 'string'
      @objects.push $.extend({},@constructor.defaultObjectOpt,objData)
    null

  render: ->
    this.$el.html(@template(
      t: i18n.t
    ))
    @$el.append(@solarSystem.render().el)
    @setLightYearsLabel(0)
    @

  onLoadingStep: (ratio)->
    console.log "Step: #{ratio}"
    @setLightYearsLabel(ratio)
    @$el.find('#loadBarInner').css width: ratio*100 + "%"

  onLoadingComplete: ()->
    @$el.find('#loadUniverseView').addClass('loadingComplete')
    @$el.find('#leftSide').one 'transitionend', =>
      @$el.find('#loadUniverseView').remove()
    # Need to remove the loadUniverseViewHere
    @setLightYearsLabel(1, false)
    @$el.find('#loadBarInner').css width: "100%"

  setLightYearsLabel: (ratio, addRandom = true)->
    $lightYearsLabel = @$el.find('#distanceMessage')

    if ratio < 0.8
      @lastLightYears = Math.round((1 - ratio) * @totalLightYears)
      if addRandom
        @lastLightYears += Math.random()*1000

      $lightYearsLabel.text(i18n.t('loading.remainingDistance', lightYears: Math.round(@lastLightYears)))
    else
      $lightYearsLabel.text(i18n.t('loading.decelerating'))

  # This method returns a deferred object, so you must use paint().done(callback) to ensure
  # the first paint has finished (meaning that all images has been loaded from server and painted)
  paint: ->
    promise = $.Deferred()
    @promiseAllImages.done =>
      @paintStrategy.prepareScene(@objects, @constructor.totalObjects)
      @loadTracker.step()
      @paintStrategy.paint()
      promise.resolve()
    promise