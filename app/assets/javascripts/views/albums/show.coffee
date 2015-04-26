class Priphea.Views.AlbumsShow extends Backbone.View

  template: JST['albums/show']

  initialize: (id) ->
    @id = id
    @album = new Priphea.Models.Album({ id: @id })
    @album.fetch()
    @album.on('change', @render, this)
    console.log("Fetching album ID: #{@id}")

  render: ->
    console.log("Rendering AlbumShow")
    console.log("#{@album?}")
    console.log("#{@album?.attributes?}")
    console.log("#{@album?.attributes.songs?}")
    $(@el).html(@template(album: @album))
    this
