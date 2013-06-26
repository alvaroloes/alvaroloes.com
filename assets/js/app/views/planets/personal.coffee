class MyUniverse.Views.Personal extends MyUniverse.Views.Planet
  template: JST['templates/planets/personal']
  className: 'personal'
  initialize: ->
    super

  render: ->
    super =>
      @$el.html(@template())
      @


