window.Priphea =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
    new Priphea.Routers.Albums()
    Backbone.history.start()

    player = new Player
    player.apiUpdateStatus(true)
    clearInterval(window.updateStatusIntervalId)
    window.updateStatusIntervalId = setInterval(player.apiUpdateStatus, 1000)


$(document).ready ->
  Priphea.initialize()

  albumRouter = new Priphea.Routers.Albums()
  albumRouter.navigate("#albums", { trigger: true })
