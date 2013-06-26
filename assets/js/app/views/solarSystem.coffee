class MyUniverse.Views.SolarSystem extends MyUniverse.Views.View
  template: JST['templates/solarSystem']
  className: 'solarSystem'


  initialize: ->
    @sun = new MyUniverse.Views.Sun()
    @planets =
      personal: new MyUniverse.Views.Personal()

  render: ->
    @$el.html(@template())
        .append(@sun.render().el)
    @$el.append(planet.render().el) for name,planet of @planets
    @


