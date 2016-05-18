let controllers = angular.module('controllers', []);
let directives = angular.module('directives', []);

let albumBrowser = function() {
  return {
    restrict: 'E',
    templateUrl: 'angular/album_browser/albumBrowser.html',
    controller: ['$scope', '$http', 'AlbumSelectionService', albumBrowserController]
  };
};
directives.directive('albumBrowser', albumBrowser);

let albumBrowserController = function($scope, $http, AlbumSelectionService) {
  $http.get('/api/albums').
    success(
      function(data) {
        $scope.albums = data;
      }
    );

  $scope.showAlbum = AlbumSelectionService.setSelectedAlbum;
};
