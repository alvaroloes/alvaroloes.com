class MyUniverse.Views.Sun extends MyUniverse.Views.View
  template: JST['templates/sun']
  className: 'sun'


  initialize: ->

  render: ->
    @$el.html(@template())
    @


