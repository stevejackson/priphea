$ ->
  localStorage.setItem("paused", false)

  $(".album a").on("dblclick", ->
    albumId = $(this).data("album-id")

    albumRouter = new Priphea.Routers.Albums
    albumRouter.navigate("#albums/" + albumId + "/play", { trigger: true })
  )

  # data = $('#album_invisible .album')
  # stringData = []
  #
  # $.each(data, (index, value) ->
  #   stringData.push($(value)[0].outerHTML)
  # )
  #
  # console.log stringData[0]
  # console.log stringData[1]
  #
  # clusterize = new Clusterize({
  #     rows: stringData,
  #     scrollId: 'cover_art_gallery',
  #     contentId: 'content_area',
  #     rows_in_block: 150
  # })
