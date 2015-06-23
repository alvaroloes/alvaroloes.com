global = exports ? this

# It's a deferred object
class global.ImageLoader

  constructor: ->
    $.extend(this,$.Deferred())


  loadImages: (@sources)->
    @images = {}
    @loadedImages = 0
    for src in @sources
      @images[src] = new Image()
      @images[src].onload = => @onLoad()
      @images[src].src = src

  onLoad: ->
    @loadedImages++
    @notify(@loadedImages, @sources.length)
    if @loadedImages >= @sources.length
      @resolve()

