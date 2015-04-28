class @Player
  instance = null # singleton instance

  constructor: ->
    # handle creation of singleton
    if instance
      return instance
    else
      instance = this

  setActiveSong: (songId) ->
    localStorage.setItem("activeSong", songId)
    localStorage.setItem("paused", "false")

  playActiveSong: ->
    songId = localStorage.getItem("activeSong")
    console.log("Playing active song: #{songId}")

    currentlyPaused = localStorage.getItem("paused")

    console.log("Paused: #{currentlyPaused}")
    console.log("player already exists?: #{window.player?}")

    # if we're currently paused, don't load an entirely new song, just resume it
    if (currentlyPaused == "true") and (window.player?)
      console.log("Paused, just resuming.")
      window.player.play()
    else
      console.log("Creating new song from URL and playing...")
      if window.player?
        window.player.stop()

      window.player = AV.Player.fromURL("/api/songs/#{songId}")
      window.player.play()

    window.player.play()

    output = "<a href='#'> <i class='pause-play-icon fa fa-pause fa-2x'></i> </a>"

    $("#play_pause_button").html(output)

    $("#play_pause_button").off("click")
    $("#play_pause_button").on("click", @handlePausePlayClick)

  pauseActiveSong: ->
    console.log("Pausing song.")
    localStorage.setItem("paused", "true")
    window.player.pause()

    output = "<a href='#'> <i class='pause-play-icon fa fa-play fa-2x'></i> </a>"
    $("#play_pause_button").html(output)


  handlePausePlayClick: (event) ->
    console.log("-----")
    console.log("handling pause play click event")
    icon = $('.pause-play-icon')

    # this instance is corrupted, so just make a new instance to call of self
    p = new Player

    if icon.hasClass('fa-pause')
      console.log("Preparing to pause..")
      p.pauseActiveSong()
    else
      console.log("Preparing to play..")
      p.playActiveSong()
