#= require_tree ./config
#= require_self
#= require ./controllers/controller
#= require ./views/view
#= require_tree .

window.MyUniverse = new ( Backbone.View.extend
  # Classes namespaces
  Controllers: {}
  Models: {}
  Collection: {}
  Views: {}
  # Instances namespaces
  views: {}

  el: document.body
  events:
    'click a': (e)->
      e.preventDefault()
      Backbone.history.navigate e.target.pathname, trigger: true

  start: ->
    new MyUniverse.Controllers.Universe()
    Backbone.history.start({pushState: true})
)

$ ->
  i18n.init({
    lng: 'es',
    fallbackLng: 'es'
    resGetPath: '/locales/__lng__/__ns__.json'
  }, ->
    window.t = i18n.t
    MyUniverse.start()
  );
