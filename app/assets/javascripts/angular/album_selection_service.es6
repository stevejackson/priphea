let services = angular.module("services");

let albumSelectionService = function() {
  let albumId = null;

  function getSelectedAlbum() {
    return albumId;
  }

  function setSelectedAlbum(newAlbumId) {
    albumId = newAlbumId;
  }

  return {
    getSelectedAlbum: getSelectedAlbum,
    setSelectedAlbum: setSelectedAlbum
  };
};
services.factory("AlbumSelectionService", albumSelectionService);
