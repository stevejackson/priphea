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

  albumRouter = new Priphea.Routers.Albums()
  albumRouter.navigate("#albums", { trigger: true })
