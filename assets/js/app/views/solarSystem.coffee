class MyUniverse.Views.SolarSystem extends MyUniverse.Views.View
  template: JST['templates/solarSystem']
  className: 'solarSystem'

  initialize: ->
    @sun = new MyUniverse.Views.Sun()
    @planets =
      personal: new MyUniverse.Views.Personal()
      reflexive: new MyUniverse.Views.Reflexive()
      labor: new MyUniverse.Views.Labor()
      technological: new MyUniverse.Views.Technological()

  render: ->
    @$el.html(@template())
        .append(@sun.render().el)
    @$el.append(planet.render().el) for name, planet of @planets
    @

  goTo: (celestialObject = 'sun')->
    @$el.attr('goto',celestialObject)


