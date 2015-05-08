$ ->
  window.recalculateSizes = ->
    marginTop = parseInt($('#hangbar').css('marginTop'))
    marginBottom = parseInt($('#hangbar').css('marginBottom'))
    hangbarHeight = parseInt($('#hangbar').height())
    aboveHeight = hangbarHeight + marginTop + marginBottom

    windowHeight = $(window).height() - aboveHeight;

    # sidebar
    $('#sidebar').css('height', windowHeight)

    # cover art gallery
    coverArtPercent = 0.70;
    galleryHeight = windowHeight * coverArtPercent
    $('#cover_art_gallery').css('height', galleryHeight)

    # song list
    songListHeight = windowHeight * (1.00 - coverArtPercent)
    $('#song_list').css('height', songListHeight)

  window.recalculateSizes()
  $(window).resize(window.recalculateSizes)
