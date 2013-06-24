class MyUniverse.Views.Universe extends MyUniverse.Views.View
  template: JST['templates/universe']
  className: 'universe'
  @totalObjects = 200
  @defaultObjectOpt:
    maxCount: null
    opacityLimits: [0.5,1]
    sizeLimits: [0.1,0.8]
    sizeUnits: 'em'


  initialize: ->
    @objects = []
    @addObjects [
      'assets/img/universe/espiral.svg'
      'assets/img/universe/estrella4puntas.svg'
      'assets/img/universe/estrella5puntas.svg'
      'assets/img/universe/estrella6puntas.svg'
    ]

  render: ->
    @$el.html(@template())
    @shuffleObjects()
    @

  addObjects: (objects)->
    for o in objects
      objData = o
      objData = {src: o} if $.type(o) is 'string'
      @objects.push $.extend({},@constructor.defaultObjectOpt,objData)

  shuffleObjects: ->
    i = 0
    nObj = @objects.length
    while i++ < @constructor.totalObjects
      o = @objects[Math.floor(Math.random() * nObj)]
      size = "#{o.sizeLimits[0] + Math.random() * (o.sizeLimits[1] - o.sizeLimits[0])}#{o.sizeUnits}"
      $('<img/>')
        .attr(src: o.src)
        .css(
          top: "#{Math.random() * 100}%"
          left: "#{Math.random() * 100}%"
          width: size
          height: size
          opacity: o.opacityLimits[0] + Math.random() * (o.opacityLimits[1] - o.opacityLimits[0])
        )
        .addClass('object')
        .appendTo(@$el)
    null


