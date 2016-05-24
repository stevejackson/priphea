let services = angular.module('services');

let playbackQueueService = function($http) {
  var playbackQueue = [];
  var service = {};

  service.getPlaybackQueue = function() {
    return $http.get('/api/songs/playback_queue');
  };

  service.setPlaybackQueue = function(newPlaybackQueue) {
    let params = { song_queue: newPlaybackQueue };

    return $http.post('/api/player/set_song_queue', params);
  };

  return service;
};

services.factory(
  'PlaybackQueueService',
  ['$http', playbackQueueService]
);
