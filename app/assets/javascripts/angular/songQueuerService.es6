let services = angular.module('services');

let songQueuerService = function(PlaybackQueueService) {
  let service = {};

  // Has to be done via reading the DOM, currently: if the table was re-ordered,
  // that re-ordering is only reflected in the DOM
  service.queueFromSong = function (clickedSongId) {
    let songIdsToAdd = [];
    var songs = document.querySelectorAll('table#song_list_table tr');
    var encounteredClickedSong = false;

    for (var i = 0; i < songs.length; i++) {
      var element = angular.element(songs[i]);
      var elementSongId = element.data('song-id');

      if (elementSongId === clickedSongId) {
        encounteredClickedSong = true;
      }

      if (encounteredClickedSong) {
        songIdsToAdd.push(elementSongId);
      }
    }

    PlaybackQueueService.setPlaybackQueue(songIdsToAdd);
  };

  return service;
};

services.factory(
  'SongQueuerService',
  ['PlaybackQueueService', songQueuerService]
);
