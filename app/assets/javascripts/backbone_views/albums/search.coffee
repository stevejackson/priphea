class Priphea.Views.AlbumsSearch extends Backbone.View

  template: JST['albums/search']

  initialize: (query) ->
    @query = query
    @albums = new Priphea.Collections.Albums()

    params = {
      'q': {
        'search_terms_special_match': @query
      }
    }

    @albums.on('reset', @render, this)
    @albums.fetch({
      data: $.param(params),
      reset: true
    })

  render: ->
    console.log("Rendering Album#Search")
    console.log("Rendering #{@albums.length} albums...")
    $(@el).html(@template(albums: @albums))
    @applyJquery()
    this

  applyJquery: ->
    $(".album a").on("dblclick", ->
      albumId = $(this).data("album-id")

      albumRouter = new Priphea.Routers.Albums
      albumRouter.navigate("#albums/" + albumId + "/play", { trigger: true })
    )

    $(".album a").on("contextmenu", (e) ->
      e.preventDefault()

      albumId = $(this).data("album-id")

      window.location.href = "/albums/" + albumId + "/edit"

      return false
    )

    $('img.lazy').lazyload({
      container: $('#cover_art_gallery'),
      effect: 'fadeIn'
    })