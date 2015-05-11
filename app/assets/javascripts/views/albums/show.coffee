class Priphea.Views.AlbumsShow extends Backbone.View

  template: JST['albums/show']

  initialize: (id, playFirstSong, empty) ->
    @id = id
    @album = new Priphea.Models.Album({ id: @id })
    @empty = empty

    unless @empty == true
      console.log "FETCHING"
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
    if $('table#song_list_table tr').length > 1
      # enable sorting by rating, via data-sort-value
      if $('table#song_list_table tr').length > 1
        $('table#song_list_table').tablesorter({
          # enable sorting by rating, via data-sort-value
          textExtraction: (node) ->
            attr = $(node).attr('data-sort-value')
            if typeof attr != 'undefined' && attr != false
              return attr
            return $(node).text()
        })

    $('table#song_list_table th.now_playing').off('click')

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
