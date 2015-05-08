class Priphea.Views.NowPlaying extends Backbone.View

  template: JST['now_playing']

  initialize: (songId) ->
    @songId = songId
    @song = new Priphea.Models.Song({ id: @songId })
    @song.fetch()
    @song.on('change', @render, this)

    console.log("Fetching song ID: #{@id}")

  render: ->
    console.log("Rendering NowPlaying")
    $(@el).html(@template(song: @song))
    @applyJquery()
    this

  applyJquery: ->
    # apply the "seek" handler to the progress bar.
    $("#progress_bar progress").on('click', (e) ->
      percent = e.offsetX / $(this).width() * 100;
      
      player = new Player
      player.apiSeek(percent)
    )
