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

# converts "3400" as milliseconds to "00:03"
secondsToReadableString = (sec) ->
  x = sec
  seconds = x % 60
  x /= 60
  minutes = x % 60
  x /= 60
  hours = x % 24
  x /= 24
  days = x

  sprintf("%02d:%02d", minutes, seconds)

generateStarRatingHTML = (rating) ->
  ratingHtml = ""
  i = 0
  while i < 10
    if i < rating # filled star
      ratingHtml += "<i class='fa fa-star' data-star-number='" + (i+1) + "'></i>"
    else # empty star
      ratingHtml += "<i class='fa fa-star-o' data-star-number='" + (i+1) + "'></i>"

    i++

  ratingHtml

class @Player
  instance = null # singleton instance

  constructor: ->
    # handle creation of singleton
    if instance
      return instance
    else
      instance = this

  apiSetSongQueue: (songQueue) ->
    params = {
      "song_queue": songQueue
    }

    $.post("/api/player/set_song_queue", params)
    console.log("Sent API request to set play queue (but don't begin playback).")

  apiSetSongQueueAndPlay: (songQueue) ->
    params = {
      "song_queue": songQueue
    }

    $.post("/api/player/set_song_queue_and_play", params)
    console.log("Sent API request to set play queue and then begin playback.")

    # set proper volume, as cmus defaults to 100 otherwise.
    value = $("#volume_control").val()
    @apiSetVolume(value)

  apiPause: ->
    $.get("/api/player/pause")
    console.log("Sent API request to pause playback.")

  apiResume: ->
    $.get("/api/player/resume")
    console.log("Sent API request to resume playback.")

  apiSeek: (percent) ->
    params = {
      percent: percent
    }

    $.post("/api/player/seek", params, (data) ->
      player = new Player
      player.apiUpdateStatus()
    )

    console.log("Sent API request to seek to #{percent}")

  apiSetVolume: (volumePercent) ->
    params = {
      volume: volumePercent
    }
    $.post("/api/player/set_volume", params)
    console.log("Sent API request to set volume to #{volumePercent}.")

  # "hardReset" is whether or not to re-render the entire now_playing area with
  # the latest data.
  apiUpdateStatus: (hardReset) ->
    $.get("/api/player/update_and_get_status", (data) ->
      console.log "Received successful api status update response."
      player = new Player
      player.updatePlayerStatus(data, hardReset)
    )
    console.log "Sent request for status update."

  apiNextSong: ->
    $.post("/api/player/next_song")
    console.log "Sent request to move to next song."

  setActiveSong: (songId) ->
    localStorage.setItem("activeSong", songId)

    songQueue = [songId]
    @apiSetSongQueue(songQueue)

  # called to begin new playback of a selected song, NOT to resume
  playActiveSong: ->
    songId = localStorage.getItem("activeSong")
    console.log("Playing active song: #{songId}")

    @apiSetSongQueueAndPlay([songId])
    @updateActiveSongIcon()
    @renderNowPlayingView(songId)


    ###### Update pause/play icon to "can pause" icon
    localStorage.setItem("paused", "false")

    output = "<a href='#'> <i class='pause-play-icon fa fa-pause fa-2x'></i> </a>"

    $("#play_pause_button").html(output)

    $("#play_pause_button").off("click")
    $("#play_pause_button").on("click", @handlePausePlayClick)

    ###### Begin interval polling of song status
    clearInterval(window.updateStatusIntervalId)
    window.updateStatusIntervalId = setInterval( ->
        player = new Player
        player.apiUpdateStatus(false)
      , 1000
    )

  # called resume playback of the current song
  resume: ->
    localStorage.setItem("paused", "false")
    songId = localStorage.getItem("activeSong")
    console.log("Resuming active song: #{songId}")

    @apiResume()

    output = "<a href='#'> <i class='pause-play-icon fa fa-pause fa-2x'></i> </a>"

    $("#play_pause_button").html(output)

    $("#play_pause_button").off("click")
    $("#play_pause_button").on("click", @handlePausePlayClick)

  updateActiveSongIcon: ->
    songId = localStorage.getItem("activeSong")

    $("tr td.now_playing.active").removeClass("active").html("")
    $("tr[data-song-id='" + songId + "'] td.now_playing").addClass("active").html("<i class='fa fa-volume-up'></i>")

  pause: ->
    console.log("Pausing song.")
    localStorage.setItem("paused", "true")
    @apiPause()

    output = "<a href='#'> <i class='pause-play-icon fa fa-play fa-2x'></i> </a>"
    $("#play_pause_button").html(output)


  handlePausePlayClick: (event) ->
    icon = $('.pause-play-icon')

    # this instance is corrupted, so just make a new instance to call of self
    p = new Player

    if icon.hasClass('fa-pause')
      p.pause()
    else
      p.resume()

  updatePlayerStatus: (status, hardReset) ->
    console.log("Updating player status with response")
    console.log status
    return false if !status or !status["song"] or !status["song"]["id"]
    currentSong = status["song"]["id"]
    localCurrentSong = localStorage.getItem("activeSong")

    # if the active song has changed, re-render the now playing area
    if hardReset == true or (currentSong != localCurrentSong)
      console.log "Re-rendering entire now playing area"
      localStorage.setItem("activeSong", currentSong)
      @renderNowPlayingView(currentSong)
      @updateActiveSongIcon()

    # always update the stuff that changes often (progress bar, song duration)
    progressBar = $("#now_playing #progress_bar progress")

    currentTime = status["position"] # seconds
    totalDuration = status["duration"] # seconds

    if currentTime? and totalDuration?
      percent = (currentTime / totalDuration) * 100

      unless isNaN(percent)
        $("#now_playing #progress_bar progress").val(percent)

    readableTotal = secondsToReadableString(totalDuration)
    readableCurrent = secondsToReadableString(currentTime)

    $("#now_playing #total_length").text(readableTotal)
    $("#now_playing #current_time").text(readableCurrent)

  renderNowPlayingView: (songId) ->
    nowPlayingView = new Priphea.Views.NowPlaying(songId)
    $('div#now_playing').html(nowPlayingView.render().el)

  selectedSongInAlbumSongList:  ->
    console.log "SelectedSongInAlbumList function called to re-evaluate playQueue"
    window.playQueue = []

    currentlyPlaying = localStorage.getItem("activeSong")
    console.log "Currently playing: #{currentlyPlaying}"

    songElements = $("#song_list_table tr")

    # sit 1: double click album. Album replaces entire playQueue. this is used.
    # sit 2: playlist clicked: replaces entire playQueue.
    # sit 3: click song halfway through album list. that's when this is used.

    # loop through each song in the #song_list.
    # once we find the song currently playing, then start adding
    # the elements after it to the song queue.

    foundCurrentSong = false
    $.each(songElements, (index, value) =>
      songId = $(value).data('song-id')

      if currentlyPlaying? and songId? and songId == currentlyPlaying
        foundCurrentSong = true

      if songId? and foundCurrentSong
        window.playQueue.push(songId)
    )

    @apiSetSongQueue(window.playQueue)
    console.log "Items in play queue: #{window.playQueue.length}"

  renderSongRatings: ->
    console.log "Rendering song ratings..."
    songs = $('table#song_list_table tr')

    $.each(songs, (index, value) ->
      p = new Player
      p.renderSingleSongRating($(value), false)
    )

    $('table#song_list_table td.rating i').off('click')
    $('table#song_list_table td.rating i').on('click', @ratingClickHandler)

  ratingClickHandler: (e) ->
    e.stopPropagation() # don't activate other click handlers

    starNumber = $(this).data('star-number')
    starNumberInt = parseInt(starNumber)

    songId = $(this).closest('tr').data('song-id')

    # update song in the database
    song = new Priphea.Models.Song({ id: songId })

    song.set({
      rating: starNumberInt * 10 # Convert star number to "out of 100" rating system
    })

    song.save()

    # update the DOM storing the rating
    $(this).closest('td').attr('data-rating', starNumberInt * 10)
    $(this).closest('td').data('rating', starNumberInt * 10)

    # re-render this song's rating now that it's updated
    p = new Player
    p.renderSingleSongRating($(this).closest('tr'), true)

    console.log "Should have synced song rating."

  renderSingleSongRating: (song_tr, clickHandler) ->
    rating_td = $(song_tr).find('td.rating')

    existing_rating = $(rating_td).data('rating')
    if existing_rating?
      existing_rating = Math.round(existing_rating / 10)
      existingRatingString = generateStarRatingHTML(existing_rating)
      $(rating_td).html(existingRatingString)
    else
      emptyRatingString = generateStarRatingHTML(0)
      $(rating_td).html(emptyRatingString)

    # reapply click handlers
    if clickHandler == true
      $('table#song_list_table td.rating i').off('click')
      $('table#song_list_table td.rating i').on('click', @ratingClickHandler)
