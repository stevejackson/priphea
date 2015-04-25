function scanLibrary(event, template) {
  var libraryFolder = $('#library_folder').val();
}

function saveSettings(event, template) {
  var libraryFolder = $('#library_folder').val();

  var settings = {
    "libraryFolder": libraryFolder
  };

  // delete existing settings collection & replace it.
  Settings.remove({});
  Settings.insert(settings);
}

Template.settings.events({
  'click #scan_library': scanLibrary,
  'click #save_settings': saveSettings
});

$(document).ready(function() {
});
