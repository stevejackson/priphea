class Priphea.Routers.Albums extends Backbone.Router
  routes:
    'song/:id/play': 'play'

  show: (id) ->
    console.log "Playing song #{id}"
    view = new Priphea.Views.Player()
