$ ->
  localStorage.setItem("paused", false)

  $(".album a").on("dblclick", ->
    albumId = $(this).data("album-id")

    albumRouter = new Priphea.Routers.Albums
    albumRouter.navigate("#albums/" + albumId + "/play", { trigger: true })
  )

  data = $('#cover_art_gallery #album')
  clusterize = new Clusterize({
      rows: data,
      scrollId: 'cover_art_gallery',
      contentId: 'content_area'
  });
