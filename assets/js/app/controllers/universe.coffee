class MyUniverse.Controllers.Universe extends MyUniverse.Controllers.Controller
  routes:
    '': 'sun'
    'sun': 'sun'
    'personal': 'personal'
    'reflexive': 'reflexive'
    'labor': 'labor'
    'tech': 'tech'
    'solarSystem': 'birdsEye'

  initialize: ->

  birdsEye: ->
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

  tech: ->
    @init ->
      MyUniverse.views.universe.solarSystem.goTo('tech')

