class Priphea.Views.AlbumsShow extends Backbone.View

  template: JST['albums/show']

  initialize: (id) ->
    @id = id
    @album = new Priphea.Models.Album({ id: @id })
    @album.fetch()
    @album.on('change', @render, this)
    console.log("Fetching album ID: #{@id}")

  render: ->
    console.log("Rendering Album#Show")
    $(@el).html(@template(album: @album))
    $('#song_list').tablesorter({ sortList: [[0,0], [1,0]] })
    @applyJquery()
    this

  applyJquery: ->
    $('#song_list tbody tr').on('click', @playSong)

  playSong: (event) ->
    songId = $(this).data('song-id')
    player = new Player
    player.setActiveSong(songId)
    player.playActiveSong()
