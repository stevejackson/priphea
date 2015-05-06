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
      if e.keyCode == 13
        beginAlbumSearch()
  )
