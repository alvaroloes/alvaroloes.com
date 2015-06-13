global = exports ? this

class global.QuotesSlider
  constructor: (el, opt = {})->
    @$el = $(el)
    @$el.addClass('quotesSlider')
    $.extend @,
      index: 0
      selectedClass: 'selected'
      deselectedClass: 'deselected'
      noTransitionClass: 'noTransition'
      shuffle: false
    , opt
    
    @build()
    
  build: ->
    @children = @$el.children().wrap('<div class="quoteContainer"/>').end().children()
    if @shuffle
      @children = $(@children.get().shuffle())
    @select(@index)
  
  select: (@index)->
    # The actual selected index becomes deselected
    @children.filter(".#{@selectedClass}")
             .removeClass(@selectedClass)
             .addClass(@deselectedClass)

    # Select the desired element
    elem = @children.eq(@index)

    # Move the element to its starting place (in case it was previously deselected)
    # with no animation
    elem.removeClass(@deselectedClass)
         .addClass(@noTransitionClass)
    reflow() # Force the browser to apply these changes

    # Select the element to start its animations
    elem.removeClass(@noTransitionClass).addClass(@selectedClass)
    
  next: ->
    @select((@index + 1) % @children.length)

     
     
    
    
   