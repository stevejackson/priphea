$ ->
  # FIXME: don't think this is actually getting called.
  Dropzone.options.albumArtUpload = {
    paramName: "file", // The name that will be used to transfer the file
    maxFilesize: 16, // MB
  };
