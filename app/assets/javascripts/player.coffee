# converts "3400" as milliseconds to "00:03"
millisecondsToReadableString = (ms) ->
  x = ms / 1000
  seconds = x % 60
  x /= 60
  minutes = x % 60
  x /= 60
  hours = x % 24
  x /= 24
  days = x

  sprintf("%02d:%02d", minutes, seconds)

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

    # update the progress bar
    @progressIntervalId = setInterval(@updateSongProgress, 75)


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

      window.player = AV.Player.fromURL("/api/song_files/#{songId}")
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
    icon = $('.pause-play-icon')

    # this instance is corrupted, so just make a new instance to call of self
    p = new Player

    if icon.hasClass('fa-pause')
      p.pauseActiveSong()
    else
      p.playActiveSong()

  updateSongProgress: ->
    if window.player?
      progressBar = $("#now_playing #progress_bar progress")

      currentTime = window.player.currentTime
      totalDuration = window.player.duration

      # console.log currentTime
      # console.log(totalDuration)

      percent = (currentTime / totalDuration) * 100

      $("#now_playing #progress_bar progress").val(percent)


      readableTotal = millisecondsToReadableString(totalDuration)
      readableCurrent = millisecondsToReadableString(currentTime)

      # console.log readableTotal
      # console.log readableCurrent

      $("#now_playing #total_length").text(readableTotal)
      $("#now_playing #current_time").text(readableCurrent)
