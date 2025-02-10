const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Lock", function () {

  async function deployOneYearLockFixture() {

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Web3PiggyVest = await ethers.getContractFactory("Web3PiggyVest");
    const web3PiggyVest = await Web3PiggyVest.deploy();

    return { web3PiggyVest, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should Owner should be able to deposit", async function () {
      const { web3PiggyVest, owner, otherAccount } = await loadFixture(deployOneYearLockFixture);

      const pay50 = ethers.BigNumber.from(50);

      await web3PiggyVest.newDeposit(1738942823, "New Laptop", {value: pay50});

      const myBalanceData = await web3PiggyVest.getMyBalanceAndSavings();

      expect(myBalanceData.balance).to.equal(50);
      expect(myBalanceData.amountAndTime.amountAndTime[0].amount).to.equal(50);
      expect(myBalanceData.amountAndTime.savingPurpose).to.be("New Laptop");
    });

    it("Should Owner should be able to deposit the second time", async function () {
      const { web3PiggyVest, owner, otherAccount } = await loadFixture(deployOneYearLockFixture);

      const pay50 = ethers.BigNumber.from(50);

      const pay20 = ethers.BigNumber.from(50);

      await web3PiggyVest.newDeposit(1738942823, "New Laptop", {value: pay50});

      await web3PiggyVest.newDeposit(1738942823, "Travel to Spain", {value: pay20});

      const myBalanceData = await web3PiggyVest.getMyBalanceAndSavings();

      expect(myBalanceData.balance).to.equal(20);
      expect(myBalanceData.amountAndTime.amountAndTime[0].amount).to.equal(70);
      expect(myBalanceData.amountAndTime.savingPurpose).to.be("Travel to Spain");
    });

    it("Should be able to withdraw", async function () {
      const { web3PiggyVest, owner, otherAccount } = await loadFixture(deployOneYearLockFixture);

      await web3PiggyVest.newDeposit(1738942823, "New Laptop", {value: 50});

      await web3PiggyVest.newDeposit(1738942823, "Travel to Spain", {value: 20});

      expect(await web3PiggyVest.withdraw(1)).to.reverted();
    });

  });
});
