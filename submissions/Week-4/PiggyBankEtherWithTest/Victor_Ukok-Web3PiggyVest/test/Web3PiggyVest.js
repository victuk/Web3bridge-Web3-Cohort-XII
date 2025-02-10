const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Web3PiggyVest Test", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function web3PiggyVestFixture() {

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Web3PiggyVest = await ethers.getContractFactory("Web3PiggyVest");
    const web3PiggyVest = await Web3PiggyVest.deploy();

    return { web3PiggyVest, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("User and contract should have the right balance", async function () {
      const { web3PiggyVest, owner, otherAccount } = await loadFixture(web3PiggyVestFixture);

      const zeroBalance = ethers.parseEther("0");

      const contractBalance = await ethers.provider.getBalance(web3PiggyVest);

      const ownerBalance = await ethers.provider.getBalance(owner);
      const otherAccountBalance = await ethers.provider.getBalance(otherAccount);

      console.log("contractBalance", ethers.formatEther(contractBalance), "zeroBalance", ethers.formatEther(zeroBalance));
      console.log("contractBalance", ethers.formatEther(contractBalance), "zeroBalance", ethers.formatEther(zeroBalance));
      console.log("ownerBalance", ethers.formatEther(ownerBalance), "otherAccountBalance", ethers.formatEther(otherAccountBalance));

      expect(contractBalance).to.equal(zeroBalance);
    });
  });

  describe("Deposit and withdrawals", () => {
    it("Should be able to deposit", async () => {
      const { web3PiggyVest, owner, otherAccount } = await loadFixture(web3PiggyVestFixture);

      const depositAmount = ethers.parseUnits("10", 18);

      const ownerBalanceBeforeDeposit = await ethers.provider.getBalance(owner);

      const deposit = await web3PiggyVest.connect(owner).newDeposit(1739081114000, "Buy a new laptop", {value: depositAmount});

      const contractBalance = await ethers.provider.getBalance(web3PiggyVest);
      const ownerBalance = await ethers.provider.getBalance(owner);

      const ownerBalanceLeft = ownerBalanceBeforeDeposit - depositAmount;

      expect(deposit).to.emit(owner.address, depositAmount, time.latest());
      expect(contractBalance).to.equal(depositAmount);
      expect(ownerBalance.toString().slice(0, 4)).to.equal(ownerBalanceLeft.toString().slice(0, 4));

    });

    it("Should be able to check balance and savings made", async () => {
      const { web3PiggyVest, owner, otherAccount } = await loadFixture(web3PiggyVestFixture);

      const depositAmount = ethers.parseUnits("10", 18);

      const ownerBalanceBeforeDeposit = await ethers.provider.getBalance(owner);

      const deposit = await web3PiggyVest.connect(owner).newDeposit(1739081114000, "Buy a new laptop", {value: depositAmount});

      const contractBalance = await ethers.provider.getBalance(web3PiggyVest);
      const ownerBalance = await ethers.provider.getBalance(owner);

      const ownerBalanceLeft = ownerBalanceBeforeDeposit - depositAmount;

      const ownerBalanceFromCalledFunction = await web3PiggyVest.connect(owner).getMyBalanceAndSavings();

      expect(deposit).to.emit(owner.address, depositAmount, time.latest());
      expect(contractBalance).to.equal(depositAmount);
      expect(ownerBalance.toString().slice(0, 4)).to.equal(ownerBalanceLeft.toString().slice(0, 4));
      expect(ownerBalanceFromCalledFunction.balance.toString().slice(0, 4)).to.equal(contractBalance.toString().slice(0, 4));

    });

    it("Should be able to update savings", async () => {
      const { web3PiggyVest, owner, otherAccount } = await loadFixture(web3PiggyVestFixture);

      const depositAmount = ethers.parseUnits("10", 18);
      const updateAmount = ethers.parseUnits("40", 18);

      const ownerBalanceBeforeDeposit = await ethers.provider.getBalance(owner);

      await web3PiggyVest.connect(owner).newDeposit(1739081114000, "Buy a new laptop", {value: depositAmount});
      await web3PiggyVest.connect(owner).updateSavings(ethers.toBigInt(1), {value: updateAmount});

      const contractBalance = await ethers.provider.getBalance(web3PiggyVest);

      const ownerBalanceFromCalledFunction = await web3PiggyVest.connect(owner).getMyBalanceAndSavings();

      expect(ownerBalanceFromCalledFunction.balance.toString().slice(0, 4)).to.equal(contractBalance.toString().slice(0, 4));

    });

    it("Should be able to deposit and withdraw", async () => {
      const { web3PiggyVest, owner, otherAccount } = await loadFixture(web3PiggyVestFixture);

      const depositAmount = ethers.parseUnits("10", 18);

      await web3PiggyVest.connect(owner).newDeposit(1739081114000, "Buy a new laptop", {value: depositAmount});
      

      const contractBalance = await ethers.provider.getBalance(web3PiggyVest);
      
      const ownerBalance = await ethers.provider.getBalance(owner);
      
      const withdraw = await web3PiggyVest.connect(owner).withdraw(ethers.toBigInt(1));
      
      const contractBalanceAfterWithdrawal = await ethers.provider.getBalance(web3PiggyVest);

      const ownerBalanceAfterWithdrawal = await ethers.provider.getBalance(owner);

      const ownerBalanceLeft = ownerBalance + depositAmount;

      expect(withdraw).to.emit(depositAmount, time.latest());
      expect(contractBalanceAfterWithdrawal).to.equal(contractBalance - depositAmount);
      expect(ownerBalanceAfterWithdrawal.toString().slice(0, 4)).to.equal(ownerBalanceLeft.toString().slice(0, 4));
    });

    it("Should be able to deposit and withdraw", async () => {
      const { web3PiggyVest, owner, otherAccount } = await loadFixture(web3PiggyVestFixture);

      const depositAmount = ethers.parseUnits("10", 18);

      await web3PiggyVest.connect(owner).newDeposit(1739081114000, "Buy a new laptop", {value: depositAmount});
      

      const contractBalance = await ethers.provider.getBalance(web3PiggyVest);
      
      const ownerBalance = await ethers.provider.getBalance(owner);
      
      const withdraw = await web3PiggyVest.connect(owner).withdraw(ethers.toBigInt(1));
      
      const contractBalanceAfterWithdrawal = await ethers.provider.getBalance(web3PiggyVest);

      const ownerBalanceAfterWithdrawal = await ethers.provider.getBalance(owner);

      const ownerBalanceLeft = ownerBalance + depositAmount;

      expect(withdraw).to.emit(depositAmount, time.latest());
      expect(contractBalanceAfterWithdrawal).to.equal(contractBalance - depositAmount);
      expect(ownerBalanceAfterWithdrawal.toString().slice(0, 4)).to.equal(ownerBalanceLeft.toString().slice(0, 4));
    });

    it("Should not be able to withdraw if the date is in the future", async () => {
      const { web3PiggyVest, owner, otherAccount } = await loadFixture(web3PiggyVestFixture);

      const depositAmount = ethers.parseUnits("10", 18);

      await web3PiggyVest.connect(owner).newDeposit(time.increase(3600), "Buy a new laptop", {value: depositAmount});
      
      const withdraw = web3PiggyVest.connect(owner).withdraw(ethers.toBigInt(1));
  
      await expect(withdraw).to.be.revertedWith("The withdrawal date and time has not reached yet");
    });

  });
});

