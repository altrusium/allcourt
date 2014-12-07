if (typeof MochaWeb !== 'undefined'){
  MochaWeb.testOnly(function(){

    describe("a group of tests", function(){
      it("should respect equality", function(){
        chai.assert.equal(5,5);
      });
    });

    describe('a sample service test', function() {
      it('should at least work', function(){
        chai.assert.isTrue(services.accountService.returnsOpposite(false));
      });
    });
  });
}
