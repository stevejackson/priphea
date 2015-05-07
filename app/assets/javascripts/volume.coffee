$ ->

  updateVolume = ->
    console.log("Trying to update volume...")

    value = $("#volume_control").val()

    player = new Player
    player.apiSetVolume(value)

  $("#volume_control").on("change", updateVolume)

  updateVolume()
