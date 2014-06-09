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
      Backbone.history.navigate e.currentTarget.pathname, trigger: true

  start: ->
    new MyUniverse.Controllers.Universe()
    Backbone.history.start({pushState: true})
)

$ ->
  i18n.addPostProcessor "markdown", (value, key, options) ->
    parts = key.split('_')
    if parts[parts.length - 1] == 'md'
      marked value
    else
      value

  i18n.init
    lng: 'es'
    fallbackLng: 'es'
    resGetPath: '/locales/__lng__/__ns__.json'
    returnObjectTrees: true
    postProcess: 'markdown'
  , ->
    MyUniverse.start()
