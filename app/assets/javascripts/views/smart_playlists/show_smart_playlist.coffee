class Priphea.Views.ShowSmartPlaylist extends Backbone.View

  template: JST['song_list']

  initialize: (id) ->
    @id = id
    @smart_playlist = new Priphea.Models.SmartPlaylist({ id: @id })

    # place a call to /songs/ with a parameter saying to return playback_queue
    @smart_playlist.fetch()
    @smart_playlist.on('change', @render, this)

  render: ->
    console.log("Rendering Album#Show")

    console.log @smart_playlist
    $(@el).html(@template(songs: @smart_playlist.attributes['songs']))
    @applyJquery()
    this

  applyJquery: ->
    $('#song_list_table tbody tr').on('click', @playSong)
    if $('table#song_list_table tr').length > 1
      $('table#song_list_table').tablesorter({
        # enable sorting by rating, via data-sort-value
        textExtraction: (node) ->
          attr = $(node).attr('data-sort-value')
          if typeof attr != 'undefined' && attr != false
            return attr
          return $(node).text()
      })

    player = new Player
    player.updateActiveSongIcon()
    player.renderSongRatings()

  playSong: (event) ->
    songId = $(this).data('song-id')

    player = new Player
    player.setActiveSong(songId)
    player.playActiveSong()

    player.selectedSongInAlbumSongList()
