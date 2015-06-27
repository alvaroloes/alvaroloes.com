global = exports ? this

class global.QuotesSlider
  constructor: (el, opt = {})->
    @$el = $(el)
    @$el.addClass('quotesSlider')
    $.extend @,
      selectedClass: 'selected'
      deselectedClass: 'deselected'
      noTransitionClass: 'clearTransitions'
      shuffle: false
      quoteScrollSpeed: 15 #In pixels/seconds
      delayBeforeNextQuote: 10 #In seconds
    , opt

    @playing = false
    @nextTimeoutID = null
    @index = -1

    @build()
    
  build: ->
    @children = @$el.children().wrap('<div class="quoteContainer"><div class="quoteScroller"></div></div>').end().children()
    if @shuffle
      @children = $(@children.get().shuffle())

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

    # Scroll the quote if needed
    delta = Math.max(0,scroller.outerHeight() - elem.outerHeight())
    scroller.removeClass(@noTransitionClass)
            .css
              transitionDuration: (delta / @quoteScrollSpeed) + 's'
              marginTop: "-#{delta}px"
    
  next: ->
    @select((@index + 1) % @children.length)
    @setNextQuoteTimer() if @playing

  play: ->
    @playing = true
    @next()

  stop: ->
    @playing = false
    clearTimeout(@nextTimeoutID)

  setNextQuoteTimer: ->
    elem = @children.eq(@index)
    scroller = elem.children()
    animDurationPlusScrollerDelay = parseFloat(scroller.css('transitionDelay'))
    scrollerDuration = parseFloat(scroller.css('transitionDuration'))
    totalTimeInSeconds = animDurationPlusScrollerDelay + scrollerDuration + @delayBeforeNextQuote
    @nextTimeoutID = setTimeout =>
      @next()
    , totalTimeInSeconds * 1000

     
     
    
    
   