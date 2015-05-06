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

  setActiveSong: (songId) ->
    localStorage.setItem("activeSong", songId)
    localStorage.setItem("paused", "false")

    # update the progress bar
    @progressIntervalId = setInterval(@updateSongProgress, 75)


  playActiveSong: ->
    songId = localStorage.getItem("activeSong")
    console.log("Playing active song: #{songId}")

    nowPlayingView = new Priphea.Views.NowPlaying(songId)
    $('div#now_playing').html(nowPlayingView.render().el)

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
      value = $("#volume_control").val()
      window.player.volume = value
      window.player.preload()
      window.player.on('buffer', @buffered)
      window.player.play()
      window.player.on('end', @playNextSongInQueue)

    output = "<a href='#'> <i class='pause-play-icon fa fa-pause fa-2x'></i> </a>"

    $("#play_pause_button").html(output)

    $("#play_pause_button").off("click")
    $("#play_pause_button").on("click", @handlePausePlayClick)

    @updateActiveSongIcon()

  buffered: (percent) ->
    console.log(percent)

  updateActiveSongIcon: ->
    songId = localStorage.getItem("activeSong")

    $("tr td.now_playing.active").removeClass("active").html("")
    $("tr[data-song-id='" + songId + "'] td.now_playing").addClass("active").html("<i class='fa fa-volume-up'></i>")


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

      if currentTime? and totalDuration?
        percent = (currentTime / totalDuration) * 100

        unless isNaN(percent)
          $("#now_playing #progress_bar progress").val(percent)

      readableTotal = millisecondsToReadableString(totalDuration)
      readableCurrent = millisecondsToReadableString(currentTime)

      $("#now_playing #total_length").text(readableTotal)
      $("#now_playing #current_time").text(readableCurrent)

  selectedSongInAlbumSongList:  ->
    console.log "SelectedSongInAlbumList function called to re-evaluate playQueue"
    window.playQueue = []

    currentlyPlaying = localStorage.getItem("activeSong")
    console.log "Currently playing: #{currentlyPlaying}"

    songElements = $("#song_list tr")

    # sit 1: double click album. Album replaces entire playQueue.
    # sit 2: playlist clicked: replaces entire playQueue
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

    console.log "Items in play queue: #{window.playQueue.length}"


  playNextSongInQueue: =>
    console.log "-----------------"
    console.log("Playing next song in queue...")
    console.log("Song queue: #{window.playQueue}")

    if window.playQueue? && window.playQueue.length > 0
      # Remove first item from queue
      window.playQueue.shift()

      console.log "#{window.playQueue.length} items left in queue."

      if window.playQueue.length > 0
        console.log(this)
        @setActiveSong(window.playQueue[0])
        @playActiveSong()

  renderSongRatings: ->
    console.log "Rendering song ratings..."
    songs = $('table#song_list_table tr')

    $.each(songs, (index, value) ->
      p = new Player
      p.renderSingleSongRating($(value))
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
    p.renderSingleSongRating $(this).closest('tr')

    console.log "Should have synced song rating."

  renderSingleSongRating: (song_tr) ->
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
    $('table#song_list_table td.rating i').off('click')
    $('table#song_list_table td.rating i').on('click', @ratingClickHandler)
