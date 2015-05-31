window.scrollToAlbum = (id) ->
  console.log "Scrolling to Album #{id}"

  albumSelector = "#album_#{id}"
  albumTop = $(albumSelector).position().top - $('#hangbar').height() - 20

  currentScrollTop = $("#cover_art_gallery").scrollTop()

  $("#cover_art_gallery").animate({
    scrollTop: albumTop + currentScrollTop
  }, "slow")
  
$ ->
  localStorage.setItem("paused", false)

  beginAlbumSearch = ->
    query = $('input#search').val()

    albumRouter = new Priphea.Routers.Albums()
    if query? && query.length > 0
      albumRouter.navigate("#search/" + query, { trigger: true })
    else
      albumRouter.navigate("#albums", { trigger: true })

  $('input#search').on('blur copy paste cut change', beginAlbumSearch)
  $('input#search').keyup( (e) ->
      e.preventDefault()
      if e.keyCode == 13
        beginAlbumSearch()
  )

  $('#next_song').on('click', ->
    player = new Player
    player.apiNextSong()
  )
