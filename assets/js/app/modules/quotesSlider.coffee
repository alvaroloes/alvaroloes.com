global = exports ? this

class global.QuotesSlider
  constructor: (el, opt = {})->
    @$el = $(el)
    @$el.addClass('quotesSlider')
    $.extend @,
      index: 0
      selectedClass: 'selected'
      deselectedClass: 'deselected'
      noTransitionClass: 'clearTransitions'
      shuffle: false
      quoteScrollSpeed: 15 #In pixels/seconds
    , opt
    
    @build()
    
  build: ->
    @children = @$el.children().wrap('<div class="quoteContainer"><div class="quoteScroller"></div></div>').end().children()
    if @shuffle
      @children = $(@children.get().shuffle())
#    @select(@index)
  
  select: (@index)->
    # The actual selected index becomes deselected
    @children.filter(".#{@selectedClass}")
             .removeClass(@selectedClass)
             .addClass(@deselectedClass)

    # Select the desired element
    elem = @children.eq(@index)
    scroller = elem.children()

    # Move the element to its starting place (in case it was previously deselected)
    # with no animation
    elem.removeClass(@deselectedClass)
        .addClass(@noTransitionClass)
    scroller.addClass(@noTransitionClass)
            .css(marginTop: 0)
    reflow() # Force the browser to apply these changes

    # Select the element to start its animations
    elem.removeClass(@noTransitionClass)
        .addClass(@selectedClass)

    delta = Math.max(0,scroller.outerHeight() - elem.outerHeight())
    scroller.removeClass(@noTransitionClass)
            .css
              transitionDuration: (delta / @quoteScrollSpeed) + 's'
              marginTop: "-#{delta}px"
    
  next: ->
    @select((@index + 1) % @children.length)

     
     
    
    
   