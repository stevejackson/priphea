class Priphea.Views.PlaybackQueue extends Backbone.View

  template: JST['song_list']

  initialize: () ->
    @queue = new Priphea.Collections.Songs()

    params = {
      'playback_queue': true
    }

    # place a call to /songs/ with a parameter saying to return playback_queue
    @queue.on('reset', @render, this)
    @queue.fetch({
      data: $.param(params),
      reset: true
    })


  render: ->
    console.log("Rendering Album#Show")
    $(@el).html(@template(songs: @queue))
    @applyJquery()
    this

  applyJquery: ->
    $('#song_list_table tbody tr').on('click', @playSong)
    #$('table#song_list_table').tablesorter({ sortList: [[1,0], [2,0]] })

    player = new Player
    player.updateActiveSongIcon()
    player.renderSongRatings()

  playSong: (event) ->
    console.log 'wtaffs'
    songId = $(this).data('song-id')

    player = new Player
    player.setActiveSong(songId)
    player.playActiveSong()

    player.selectedSongInAlbumSongList()
