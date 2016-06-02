let controllers = angular.module('controllers');

let albumDetailsController = function($scope, $http, $stateParams, Upload, $timeout) {
  $scope.album = null;

  let fetchAlbum = function() {
    $http.get(`/api/albums/${$stateParams.id}`).
      success(
        function(data) {
          $scope.album = data;
        }
      );
  };

  $scope.uploadPic = function(file) {
    console.log("Uploading");
    file.upload = Upload.upload({
      url: `/api/albums/${$scope.album.id}/change_album_art`,
      data: { file: file }
    });

    file.upload.then(function (response) {
        $timeout(function () {
          file.result = response.data;
        });
      }, function (response) {
        if (response.status > 0)
          $scope.errorMsg = response.status + ': ' + response.data;
      }, function (evt) {
        // Math.min is to fix IE which reports 200% sometimes
        file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total));
      });
  };

  let init = function() {
    fetchAlbum();
  };

  init();
};

controllers.controller(
  'AlbumDetailsController',
  ['$scope', '$http', '$stateParams', 'Upload', '$timeout', albumDetailsController]
);
