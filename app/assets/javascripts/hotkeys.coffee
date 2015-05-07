$ ->
  focusSearch = ->
    $('#search').focus()

  console.log 'ohe'
  Mousetrap.bind('command+f', ->
    focusSearch()
    return false
  )

  Mousetrap.bind('space', (event) ->
    player = new Player
    player.handlePausePlayClick(event)
    return false
  )
