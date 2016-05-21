$(document).ready(function() {
  function updateVolume() {
    let value = $("#volume_control").val();
    let player = new Player();

    player.apiSetVolume(value);

    $("#volume_control").blur();

    return false;
  }

  $("#volume_control").on("change", updateVolume);

  updateVolume();
});