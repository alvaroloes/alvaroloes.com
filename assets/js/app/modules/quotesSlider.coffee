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
  
  select: (@index)->
    # The actual selected index becomes deselected
    @children.filter(".#{@selectedClass}")
             .removeClass(@selectedClass)
             .addClass(@deselectedClass)

    # Select the desired element
    @elem = @children.eq(@index)
    @elem.removeClass(@deselectedClass) # In case it was previously deselected
         .addClass(@noTransitionClass)
    reflow()
    @elem.removeClass(@noTransitionClass).addClass(@selectedClass)
    
  next: ->
    @select((@index + 1) % @children.length)
    
  prev: ->
    @select((@index - 1) % @children.length)
     
     
    
    
   