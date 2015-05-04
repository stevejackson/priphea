class Priphea.Views.AlbumsShow extends Backbone.View

  template: JST['albums/show']

  initialize: (id, playFirstSong) ->
    @id = id
    @album = new Priphea.Models.Album({ id: @id })
    @album.fetch()
    @album.on('change', @render, this)

    if playFirstSong
      @album.on('change', @playFirstSong)

    console.log("Fetching album ID: #{@id}")

  render: ->
    console.log("Rendering Album#Show")
    $(@el).html(@template(album: @album))
    @applyJquery()
    this

  applyJquery: ->
    $('#song_list tbody tr').on('click', @playSong)
    $('table#song_list_table').tablesorter({ sortList: [[1,0], [2,0]] })
    player = new Player
    player.updateActiveSongIcon()
    player.renderSongRatings()

  playSong: (event) ->
    songId = $(this).data('song-id')

    player = new Player
    player.setActiveSong(songId)
    player.playActiveSong()

    player.selectedSongInAlbumSongList()

  playFirstSong: ->
    song = $('table#song_list_table tbody tr').first()

    if song?
      songId = $(song).data("song-id")

      player = new Player
      player.setActiveSong(songId)
      player.playActiveSong()

      player.selectedSongInAlbumSongList()
