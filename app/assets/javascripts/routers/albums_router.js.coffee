class Priphea.Routers.Albums extends Backbone.Router
  routes:
    'albums/:id': 'show'
    'albums/:id/play': 'show_and_play'
    'albums': 'all'
    'search': 'search'
    'search/:query': 'search'
    'playback_queue': 'playbackQueue'
    'library': 'library'
    'smart_playlists/:id': 'showSmartPlaylist'
    'now_playing_to_show_album/:id': 'nowPlayingToShowAlbum'

  show: (id) ->
    console.log "Showing album #{id}"

    view = new Priphea.Views.AlbumsShow(id, false, false)
    $('div#song_list').html(view.render().el)

  show_and_play: (id) ->
    console.log "Showing and playing album #{id}"

    view = new Priphea.Views.AlbumsShow(id, true, false)
    $('div#song_list').html(view.render().el)

  all: ->
    console.log "Showing all albums"

    view = new Priphea.Views.AlbumsSearch("")
    $("div#cover_art_gallery").html(view.render().el)

  search: (query) ->
    console.log "Searching for query: #{query}"

    view = new Priphea.Views.AlbumsSearch(query)
    $("div#cover_art_gallery").html(view.render().el)

  playbackQueue: ->
    console.log "Moving to playback queue view."

    view = new Priphea.Views.PlaybackQueue()
    $("div#browser").html(view.render().el)

  library: ->
    console.log "Moving to library view."

    # instantiate base library view
    view = new Priphea.Views.Library()
    # using "childnodes" avoids the output being wrapped in a div by default
    $("div#browser").html("").append(view.render().el.childNodes);
    recalculateSizes()

    # instantiate cover art browser
    view = new Priphea.Views.AlbumsSearch("")
    $("div#cover_art_gallery").html(view.render().el)

    # instantiate album song list
    view = new Priphea.Views.AlbumsShow(0, false, true)
    $('div#song_list').html(view.render().el)

  showSmartPlaylist: (id) ->
    console.log "Showing smart playlist: #{id}"

    view = new Priphea.Views.ShowSmartPlaylist(id)
    $("div#browser").html(view.render().el)

  # when clicking a song in the "now_playing" area, it should render the
  # library view and show that album
  nowPlayingToShowAlbum: (id) ->
    console.log "In nowPlayingToShowAlbum router"

    # instantiate base library view
    view = new Priphea.Views.Library()
    # using "childnodes" avoids the output being wrapped in a div by default
    $("div#browser").html("").append(view.render().el.childNodes);
    recalculateSizes()

    # instantiate cover art browser
    view = new Priphea.Views.AlbumsSearch("")
    $("div#cover_art_gallery").html(view.render().el)

    # instantiate album song list
    view = new Priphea.Views.AlbumsShow(0, false, true)
    $('div#song_list').html(view.render().el)

    # redirect to "show_album"
    #albumRouter = new Priphea.Routers.Albums()
    @navigate("#albums/" + id, { trigger: true })
