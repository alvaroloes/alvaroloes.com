class MyUniverse.Controllers.Sun extends MyUniverse.Controllers.Controller
  routes:
    '': 'index'

  initialize: ->

  index: ->
    @init ->
      console.log 'A trip to the sun'
      MyUniverse.views.universe.solarSystem.goTo('sun')
