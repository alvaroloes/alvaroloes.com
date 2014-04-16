class MyUniverse.Views.Sun extends MyUniverse.Views.View
  template: JST['templates/sun']
  tagName: "section"
  className: 'sun'


  initialize: ->

  render: ->
    @$el.html(@template(t:i18n.t))
    @$el.on('transitionend', (e)=> @onSectionVisible(e))
    @

  onSectionVisible: (e)->
    return if e.target != @el
    event = e.originalEvent;
    if event.propertyName == 'opacity'
      if @$el.css('opacity') > 0
        @$el.children('nav').addClass('showNav')
      else
        @$el.children('nav').removeClass('showNav')

