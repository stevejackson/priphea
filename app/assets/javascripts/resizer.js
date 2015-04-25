$(document).ready(function() {
  var recalculateSizes = function() {
    var marginTop = parseInt($('#hangbar').css('marginTop'));
    var marginBottom = parseInt($('#hangbar').css('marginBottom'));
    var hangbarHeight = parseInt($('#hangbar').height());
    var aboveHeight = hangbarHeight + marginTop + marginBottom;

    windowHeight = $(window).height() - aboveHeight;

    // sidebar
    $('#sidebar').css('height', windowHeight);

    // cover art gallery
    coverArtPercent = 0.70;
    galleryHeight = windowHeight * coverArtPercent;
    $('#cover_art_gallery').css('height', galleryHeight);

    // song list
    songListHeight = windowHeight * (1.00 - coverArtPercent);
    $('#song_list').css('height', songListHeight);
  }

  recalculateSizes();
  $(window).resize(recalculateSizes);
});
