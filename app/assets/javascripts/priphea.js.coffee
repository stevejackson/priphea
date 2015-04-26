window.Priphea =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
    new Priphea.Routers.Albums()
    Backbone.history.start()

$(document).ready ->
  Priphea.initialize()
