global = exports ? this

class global.Cylinder
  constructor: (el, opt = {})->
    @$el = $(el)
    @$el.addClass('cylinder')
    $.extend @,
      elementsOffset: 1
    , opt
    
    @build()
    
  build: ->
    @children = @$el.children();
    @childHeight = @children.outerHeight();
    @$el.height(@childHeight * (2*@elementsOffset + 1))
    @centerOn(0)
  
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
     
     
    
    
   