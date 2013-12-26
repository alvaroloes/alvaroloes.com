class MyUniverse.Views.Sun extends MyUniverse.Views.View
  template: JST['templates/sun']
  tagName: "section"
  className: 'sun'


  initialize: ->

  render: ->
    @$el.html(@template())
    @


