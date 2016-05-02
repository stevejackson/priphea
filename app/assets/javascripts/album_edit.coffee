#= require update_album_metadata_form

$ ->
  Dropzone.options.albumArtUpload = {
    paramName: "file", # The name that will be used to transfer the file
    maxFilesize: 16 # MB
  }

  metadataForm = new UpdateAlbumMetadataForm('update_album_metadata')


