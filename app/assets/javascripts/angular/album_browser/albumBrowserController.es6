let controllers = angular.module('controllers');

let albumBrowserController = function($scope, $http, PlaybackQueueService) {
  $scope.albums = [];
  $scope.selectedAlbum = null;

  $scope.showAlbum = function(albumId) {
    $http.get(`/api/albums/${albumId}`).
      success(
        function(data) {
          $scope.selectedAlbum = data;
        }
      );
  };

  // Has to be done via reading the DOM, currently: if the table was re-ordered,
  // that re-ordering is only reflected in the DOM
  $scope.addSongsToPlaybackQueueStartingAtSongId = function(clickedSongId) {
    let songIdsToAdd = [];
    var songs = document.querySelectorAll('table#song_list_table tr');
    var encounteredClickedSong = false;

    for(var i = 0; i < songs.length; i++) {
      var element = angular.element(songs[i]);
      var elementSongId = element.data('song-id');

      if(elementSongId === clickedSongId) {
        encounteredClickedSong = true;
      }

      if(encounteredClickedSong) {
        songIdsToAdd.push(elementSongId);
      }
    }

    PlaybackQueueService.setPlaybackQueue(songIdsToAdd);
  };

  let fetchAllAlbums = function() {
    $http.get('/api/albums').
    success(
      function(data) {
        $scope.albums = data;
      }
    );
  };

  let init = function() {
    fetchAllAlbums();
  };

  init();
};

controllers.controller(
  'AlbumBrowserController',
  ["$scope", "$http", 'PlaybackQueueService', albumBrowserController]
);
