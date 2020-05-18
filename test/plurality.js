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
  
    // it("should have two members", async () => {
    //   await contractInstance.updateMember(ALICE, true);

    //   const actual = await contractInstance.membersCount();
    //   assert.equal(Number(actual), 2, "Member count should be 2");
    // });

  //   it("should have three members", async () => {
  //     await contractInstance.updateMember(ALICE, true);
  //     await contractInstance.updateMember(BOB, true);

  //     const actual = await contractInstance.membersCount();
  //     assert.equal(Number(actual), 3, "Member count should be 3");
  //   });

  //   it.skip("should have two members again", async () => {
  //       await contractInstance.updateMember(ALICE, true);
  //       await contractInstance.updateMember(BOB, true);
  
  //       let actual = await contractInstance.membersCount();
  //       assert.equal(Number(actual), 3, "Member count should be 3");

  //       await contractInstance.updateMember(ALICE, false);
  //       assert.equal(Number(actual), 2, "Member count should be 2");
  //     });
  });

  describe("Vote tests", async () => {
    beforeEach(async () => {
      contractInstance = await Contract.new();
    });

    it("should grant alice 100 tokens", async () => {
      await contractInstance.grant(ALICE, 100);

      const actual = await contractInstance.balanceOf(ALICE);
      assert.equal(Number(actual), 100, "Balance should be 100");
    });

    it("should revoke 50 tokens", async () => {
      await contractInstance.grant(ALICE, 100);
      await contractInstance.revoke(ALICE, 50);

      const actual = await contractInstance.balanceOf(ALICE);
      assert.equal(Number(actual), 50, "Balance should be 50");
    });

    it("should create a proposal for alice", async () => {
      await contractInstance.grant(ALICE, 100);
      await contractInstance.addProposal("All the cows are brown");

      const actual = await contractInstance.proposals(0);
      assert.equal(actual.issue, "All the cows are brown", "Proposal issue incorrect");
    });

    it("should be in voting period", async () => {
      await contractInstance.grant(ALICE, 100);
      await contractInstance.addProposal("All the cows are brown");
      await contractInstance.proposals(0);

      const actual = await contractInstance.canVote(0)
      assert.equal(actual, true, "Proposal should be in vote period");
    });

    it("should be able to vote", async () => {
      await contractInstance.grant(ALICE, 100);
      await contractInstance.addProposal("All the cows are brown");
      await contractInstance.proposals(0);

      contractInstance.canVote(0);
      assert.equal(actual, true, "Proposal should be in vote period");
    });
  });
});
