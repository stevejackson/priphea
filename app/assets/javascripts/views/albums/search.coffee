class Priphea.Views.AlbumsSearch extends Backbone.View

  template: JST['albums/search']

  initialize: (query) ->
    @query = query

    @albums = new Priphea.Collections.Albums()

    params = { 'query': @query }
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
