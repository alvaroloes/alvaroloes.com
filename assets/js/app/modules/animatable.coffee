global = exports ? this

$ = jQuery

# It's a deferred object
class global.Animatable

  @makeAnimatable: (object, options)->
    $.extend(object, new Animatable(options))

  # Options can be:
  # - animatablePropertiesHolder: The name of the attribute inside of which animatable properties will be
  # searched. By default is null, which means they will be searched directly on "this"
  #
  constructor: (opt = {})->
    @animatable =
      props   : opt.animatablePropertiesHolder
      instant : []
      queued  : []

  # Make a transition between property values. Options:
  # - properties: An object whose keys are the properties to animate and the values are its final values.
  # - duration: The time the animation will last
  # - easing: The easing function which will define the progression of the animation. Can be any function
  # that accepts a number as input (which represents time ratio) and returns a number (the output ratio).
  # You can use here any method of the Easing class. By default is Easing.easeInOut
  # - queue: True if the animation should begin after other animations ends. False if you want it to
  # start immediately. By default is true
  transition: (options, autostart = true)->
    transition = new Transition(options)
    if autostart
      if not options.queue? or options.queue
        @animatable.queued.push transition
      else
        @animatable.instant.push transition
    transition

  # Make an animation. It consist of any number of transitions executed in order. Options
  # - transitions: An array of Transition objects. "queue" key will be ignored
  # - duration: The duration of the whole animation. The duration of each transition will be tansfromed as percentage.
  # If null is passed, the whole duration will be the sum of each transition duration. By default is null
  # - count: The number of cicles of the animation. By default is 1
  # - direction: The direction of the animation. It can be 'normal', 'reverse' or 'alternate'. By default is 'normal'
  # - queue: True if the animation should begin after other animations ends. False if you want it to
  # start immediately. By default is true
  animation: (options)->
    animation = new Animation(options)
    if not options.queue? or options.queue
      @animatable.queued.push animation
    else
      @animatable.instant.push animation
    animation

  animate: ->
    # Animate all transitions/animations in instant array
    if @animatable.props
      props = @[@animatable.props]
    else
      props = @

    i = 0
    while i < @animatable.instant.length
      anim = @animatable.instant[i]
      anim.animate(props)
      if anim.finished()
        @animatable.instant.splice(i,1)
      else
        ++i

    # Animate queued transitions/animations in order
    anim = @animatable.queued[0]
    if anim?
      anim.animate(props)
      @animatable.queued.shift() if anim.finished()



######################### EASING CLASS ########################

# Class with easing functions. Both input and output of all easing functions works with ratios
# (values between 0 and 1)
class Easing

  @cubicBezier: (t, p1, p2)->
    3*Math.pow(1-t,2)*t*p1 + 3*(1-t)*Math.pow(t,2)*p2 + Math.pow(t,3)

  @linear: (t)-> t

  @easeIn: (t)-> Easing.cubicBezier(t,0,0.5)

  @easeOut: (t)-> Easing.cubicBezier(t,0.5,1)

  @easeInOut: (t)-> Easing.cubicBezier(t,0,1)

  @backIn: (t)-> Easing.cubicBezier(t,-0.5,0.5)

  @forwardOut: (t)-> Easing.cubicBezier(t,0.5,1.5)

  @backInForwardOut: (t)-> Easing.cubicBezier(t,-0.5,1.5)


######################### TRANSITION CLASS ########################

class Transition

  # Options:
  # - properties: An object whose keys are the properties to animate and the values are its final values.
  # - duration: The time the animation will last
  # - easing: The easing function which will define the progression of the animation. Can be any function
  # that accepts a number as input (which represents time ratio) and returns a number (the output ratio).
  # You can use here any method of the Easing class. By default is Easing.easeInOut
  # - queue: True if the animation should begin after other animations ends. False if you want it to
  # start immediately. By default is true
  constructor: (options)->
    $.extend @,
      properties: {}
      duration: 1000
      easing: Easing.easeInOut
    , options

    @startTime = null
    @preparedProperties = null
    @reversed = false

  animate: (objectProps)->
    @init(objectProps) unless @started()
    # Animate each property
    elapsedTime = Date.now() - @startTime
    for prop, propLimits of @preparedProperties
      inputRatio = elapsedTime / @duration
      inputRatio = 1 if inputRatio > 1
      outputRatio = @easing(inputRatio)
      objectProps[prop] = propLimits.ini + outputRatio * (propLimits.fin - propLimits.ini)

    undefined

  init: (objectProps)->
    @startTime = Date.now()
    unless @preparedProperties
      @preparedProperties = {}
      for prop,val of @properties
        # Delete this animationg property if it doesn't exist in object properties
        unless ( currentVal = objectProps[prop] )?
          delete @properties[prop]
          continue
        @preparedProperties[prop] =
          ini: currentVal
          fin: val
    if @reverse != @reversed
      for prop, propLimits of @preparedProperties
        @preparedProperties[prop] =
          ini: propLimits.fin
          fin: propLimits.ini
    @reversed = @reverse

  finished: -> Date.now() > @startTime + @duration

  started: -> !!@startTime

  toggleReverse: (@reverse)-> @reset()

  reset: -> @startTime = null


######################### ANIMATION CLASS ########################

class Animation

  # Options
  # - transitions: An array of Transition objects. "queue" key will be ignored
  # - duration: The duration of the whole animation. The duration of each transition will be tansfromed as percentage.
  # If null is passed, the whole duration will be the sum of each transition duration. By default is null
  # - count: The number of cicles of the animation. It can be 'infinite'. By default is 1
  # - alternateDirection: If true the direction of the animation will change in each cycle. By default is false
  # - queue: True if the animation should begin after other animations ends. False if you want it to
  # start immediately. By default is true
  constructor: (options)->
    $.extend @,
      transitions: []
      count: 1
      alternateDirection: false
    , options

    @startTime = null
    @cycle = 0
    @adjustDurations()
    @prepareNewCycle()

  animate: (objectProps)->
    unless @startTime
      @startTime = Date.now()

    @prepareNewCycle() if @cycleFinished()

    return if @finished()

    transition = @transitions[@transitionIndex]
    transition.animate(objectProps)

    @transitionIndex += @transitionStep if transition.finished()

  cycleFinished: ->
    @transitionIndex >= @transitions.length or @transitionIndex < 0

  prepareNewCycle: ->
    ++@cycle
    if @alternateDirection and @cycle % 2 == 0
      @transitionIndex = @transitions.length - 1
      @transitionStep = -1
    else
      @transitionIndex = 0
      @transitionStep = 1
    @reset()

  adjustDurations: ->
    return unless @duration
    totalTransitionsDuration = 0
    for t in @transitions
      totalTransitionsDuration += t.duration
    for t in @transitions
      t.duration = @duration * t.duration/totalTransitionsDuration

    undefined

  finished: ->
    @count != 'infinite' and @cycle >= @count

  started: ->
    !!@startTime

  reset: (fullReset = false)->
    for t in @transitions
      t.reset()
      t.toggleReverse(@transitionStep < 0)

    undefined







