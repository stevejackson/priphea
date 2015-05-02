class Priphea.Routers.Albums extends Backbone.Router
  routes:
    'albums/:id': 'show'
    'albums/:id/play': 'show_and_play'

  show: (id) ->
    console.log "Showing album #{id}"
    view = new Priphea.Views.AlbumsShow(id, false)
    $('div#song_list').html(view.render().el)

  show_and_play: (id) ->
    console.log "Showing and playing album #{id}"
    view = new Priphea.Views.AlbumsShow(id, true)
    $('div#song_list').html(view.render().el)
