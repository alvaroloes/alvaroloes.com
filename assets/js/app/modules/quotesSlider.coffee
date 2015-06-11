global = exports ? this

class global.QuotesSlider
  constructor: (el, opt = {})->
    @$el = $(el)
    @$el.addClass('quotesSlider')
    $.extend @,
      random: false
    , opt
    
    @build()
    
  build: ->
    @children = @$el.children() #.wrap('<div>').end().children()
    @children.first().addClass('selected')
  
  centerOn: (@elementIndex)->
    for i in [0..@children.length]
      child = @children.eq(i)
      posY = -@elementIndex * @childHeight;
      child.css('transform','translateY(' + posY + 'px)')
    null
    
  next: ->
    @centerOn(@elementIndex + 1)
    
  prev: ->
    @centerOn(@elementIndex - 1)
     
     
    
    
   