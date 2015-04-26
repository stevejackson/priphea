class Priphea.Routers.Albums extends Backbone.Router
  routes:
    'albums/:id': 'show'

  show: (id) ->
    console.log "Showing album #{id}"
    view = new Priphea.Views.AlbumsShow(id)
    $('div#song_list').html(view.render().el)
