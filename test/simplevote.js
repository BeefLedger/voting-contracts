const Contract = artifacts.require("Plurality");

contract("Plurality", function(accounts) {
  const OWNER = accounts[0];
  const ALICE = accounts[1];
  const BOB = accounts[2];

  let contractInstance;

  describe("Tests", async () => {
    beforeEach(async () => {
        contractInstance = await Contract.new();
    });

    it("should ...", async () =>  {
        //todo
    });
});
});
