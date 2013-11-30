class MyUniverse.Controllers.Universe extends MyUniverse.Controllers.Controller
  routes:
    '': 'index'
    'sun': 'sun'
    'personal': 'personal'
    'reflexive': 'reflexive'
    'labor': 'labor'
    'technological': 'technological'

  initialize: ->

  index: ->
    @init ->
      MyUniverse.views.universe.solarSystem.goTo('birdsEye')

  sun: ->
    @init ->
      MyUniverse.views.universe.solarSystem.goTo('sun')

  personal: ->
    @init ->
      MyUniverse.views.universe.solarSystem.goTo('personal')

  reflexive: ->
    @init ->
      MyUniverse.views.universe.solarSystem.goTo('reflexive')

  labor: ->
    @init ->
      MyUniverse.views.universe.solarSystem.goTo('labor')

  technological: ->
    @init ->
      MyUniverse.views.universe.solarSystem.goTo('technological')

