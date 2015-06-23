global = exports ? this

class global.LoadTracker
  constructor: (@max, opt = {})->
    $.extend @,
      a: 3
      onStep: $.noop
      onComplete: $.noop
    , opt

    @index = 0
    @complete = false

    
  step: (delta = 1)->
    @index += delta
    if @index >= @max
      unless @complete
        @complete = true
        @onComplete?()
    else
      @onStep?(@index/@max)

  stepper: (delta = 1)->
    => @step(delta)


     
     
    
    
   