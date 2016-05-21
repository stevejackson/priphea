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

  it('should fetch albums on init', function() {
    httpBackend.expectGET('/api/albums').respond([1]);

    var $scope = {};
    var controller = $controller('albumBrowserController', { $scope: $scope });
    httpBackend.flush();
    expect($scope.albums).to.eql([1]);
  });

  describe('#showAlbum', function() {
  });
});
