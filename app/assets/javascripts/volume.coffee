$ ->

  updateVolume = ->
    console.log("Trying to volume...")
    if window.player?
      value = $("#volume_control").val()
      window.player.volume = value

      console.log("Changing volume to #{value}")
    else
      console.log("No active player, can't change volume.")

  $("#volume_control").on("change", updateVolume)
