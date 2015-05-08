class Priphea.Views.Library extends Backbone.View

  template: JST['library']

  initialize: () ->

  render: ->
    console.log("Rendering Library")
    $("div#browser").html(@template())
    this
