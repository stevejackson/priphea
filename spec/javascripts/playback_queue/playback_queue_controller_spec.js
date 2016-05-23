describe("PlaybackQueueController", function() {

  var $controller;
  var $httpBackend = null;

  beforeEach(angular.mock.module('priphea'));

  afterEach(function() {
    $httpBackend.verifyNoOutstandingExpectation();
    $httpBackend.verifyNoOutstandingRequest();
  });

  beforeEach(function() {
    angular.mock.inject(
      function (_$controller_, _$httpBackend_) {
        $controller = _$controller_;
        $httpBackend = _$httpBackend_;
      }
    );
  });

  beforeEach(function() {
    $httpBackend.expectGET('/api/songs/playback_queue').respond([1]);
  });

  it('should fetch playback queue on init', function() {
    var $scope = {};
    $controller('PlaybackQueueController', { $scope: $scope });
    $httpBackend.flush();

    expect($scope.playback_queue).to.eql([1]);
  });
});
