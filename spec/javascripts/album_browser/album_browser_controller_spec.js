describe("AlbumBrowserController", function() {

  var $controller;
  var httpBackend = null;

  beforeEach(angular.mock.module('priphea'));

  afterEach(function() {
    httpBackend.verifyNoOutstandingExpectation();
    httpBackend.verifyNoOutstandingRequest();
  });

  beforeEach(function() {
    angular.mock.inject(
      function (_$controller_, $httpBackend) {
        $controller = _$controller_;
        httpBackend = $httpBackend;
      }
    );
  });

  beforeEach(function() {
    httpBackend.expectGET('/api/albums').respond([1]);
  });

  it('should fetch albums on init', function() {
    var $scope = {};
    var controller = $controller('AlbumBrowserController', { $scope: $scope });
    httpBackend.flush();
    expect($scope.albums).to.eql([1]);
  });

  describe('#showAlbum', function() {
    it('should fetch specific album', function() {
      httpBackend.expectGET('/api/albums/abc123').respond({ 'blah': 123 });

      var $scope = {};
      var controller = $controller('AlbumBrowserController', { $scope: $scope });
      $scope.showAlbum('abc123');

      httpBackend.flush();
      expect($scope.selectedAlbum).to.eql({ 'blah': 123 });
    });
  });
});
