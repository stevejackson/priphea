describe("Filters", function() {

  var filters;

  beforeEach(function() {
    module('priphea');

    inject(function (_$filter_) {
      filters = _$filter_;
    });
  });

  describe("ratingToStarCount", function() {
    it("95 -> 10", function() {
      var result = filters('ratingToStarCount')(95);
      expect(result).to.eq(10);
    });

    it("94 -> 9", function() {
      var result = filters('ratingToStarCount')(94);
      expect(result).to.eq(9);
    });

    it("100 -> 10", function() {
      var result = filters('ratingToStarCount')(100);
      expect(result).to.eq(10);
    });
  });

});
