class MyUniverse.Views.Universe extends MyUniverse.Views.View
#  template: JST['templates/universe']
  className: 'universe'
  @totalObjects = 100
  @defaultObjectOpt:
    maxCount: null
    opacity: 'pulse' #{'pulse',<interval>}
    pulseFrecuencyInterval: [0.2,1.5]
    sizeInterval: [0.1,0.8]
    sizeUnits: 'em'
    rotateInterval: [0,360]


  initialize: ->
    # Initialize foreground elements
    @solarSystem = new MyUniverse.Views.SolarSystem()
    # Initialize background elements
    @objects = []
    @addObjects [
      'assets/img/universe/estrella4puntas.svg'
      'assets/img/universe/estrella5puntas.svg'
      'assets/img/universe/estrella6puntas.svg'
    ]
    # Special objects
    props =
      maxCount: 1
      opacity: [0.5,0.8]
      sizeInterval: [20,30]
      sizeUnits: 'px'
    @addObjects [
      $.extend({src: 'assets/img/universe/galaxia1.png'},props)
      $.extend({src: 'assets/img/universe/galaxia2.png'},props)
      $.extend({src: 'assets/img/universe/galaxia3.png'},props)
      $.extend({src: 'assets/img/universe/galaxia4.png'},props)
      $.extend({src: 'assets/img/universe/galaxia5.png'},props)
    ]

  render: ->
#    @$el.html(@template())
    @shuffleObjects()
    @$el.append(@solarSystem.render().el)
    @

  addObjects: (objects)->
    for o in objects
      objData = o
      objData = {src: o} if $.type(o) is 'string'
      @objects.push $.extend({},@constructor.defaultObjectOpt,objData)

  shuffleObjects: ->
    i = 0
    while i < @constructor.totalObjects
      o = @objects.sample()
      if o.maxCount?
        o.count ?= 0 # Private property
        continue if ++o.count > o.maxCount
      size = "#{o.sizeInterval.sampleInterval()}#{o.sizeUnits}"

      $img = $('<img/>')
        .attr(src: o.src)
        .css(
          top: "#{Math.random() * 100}%"
          left: "#{Math.random() * 100}%"
          width: size
          height: size
          transform: "rotate(#{o.rotateInterval.sampleInterval()}deg)"
        )
        .addClass('object')

      if o.opacity == 'pulse'
        $img.css animationDuration: "#{1 / (o.pulseFrecuencyInterval.sampleInterval())}s"
      else
        $img.css
          animation: 'none'
          opacity: o.opacity.sampleInterval()

      $img.appendTo(@$el)
      ++i
    null


