const Contract = artifacts.require("Plurality");

contract("Plurality", async (accounts) => {
  const OWNER = accounts[0];
  const ALICE = accounts[1];
  const BOB = accounts[2];

  let contractInstance;

  describe("Roles and permissions tests", async () => {
    beforeEach(async () => {
      contractInstance = await Contract.new();
    });

    it("should have two members", async () => {
      await contractInstance.updateMember(ALICE, true);

      const actual = await contractInstance.membersCount();
      assert.equal(Number(actual), 2, "Member count should be 2");
    });

    it("should have three members", async () => {
      await contractInstance.updateMember(ALICE, true);
      await contractInstance.updateMember(BOB, true);

      const actual = await contractInstance.membersCount();
      assert.equal(Number(actual), 3, "Member count should be 3");
    });

    it.skip("should have two members again", async () => {
        await contractInstance.updateMember(ALICE, true);
        await contractInstance.updateMember(BOB, true);
  
        let actual = await contractInstance.membersCount();
        assert.equal(Number(actual), 3, "Member count should be 3");

        await contractInstance.updateMember(ALICE, false);
        assert.equal(Number(actual), 2, "Member count should be 2");
      });
  });
});
