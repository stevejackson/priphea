describe("starBar directive", function() {

  var $rootScope, $compile;

  beforeEach(function() {
    module('priphea');
  });

  beforeEach(function() {
    inject(function (_$compile_, _$rootScope_) {
      $compile = _$compile_;
      $rootScope = _$rootScope_;
    })
  });

  it("should render a series of clickable star icons", function() {
    var element = $compile("<star-bar></star-bar>")($rootScope);
    $rootScope.$digest();

    expect(element.find("i").length).to.eq(10);
  });

});
