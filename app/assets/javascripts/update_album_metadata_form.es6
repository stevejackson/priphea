class UpdateAlbumMetadataForm {
  constructor (formElementId) {
    this.form = $("form#" + formElementId);
    this.applyHandlers();
  }

  applyHandlers() {
    $(this.form).find("input.copy").on('blur', this.copyValueToAllSongs);
  }

  copyValueToAllSongs() {
    let field = $(this).data('field');
    let value = $(this).val();

    $(this.form).find(`input.${field}`).val(value);
  }
}

