class @UpdateAlbumMetadataForm
  constructor: (formElementId) ->
    @form = $("form#" + formElementId)
    @applyHandlers()

  applyHandlers: ->
    $(@form).find("input.copy").on('blur', @copyValueToAllSongs)

  copyValueToAllSongs: ->
    field = $(this).data('field')
    value = $(this).val()

    $(@form).find("input.#{field}").val(value)
