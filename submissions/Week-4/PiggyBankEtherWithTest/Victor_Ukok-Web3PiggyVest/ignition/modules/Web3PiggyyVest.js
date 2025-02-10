// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Web3PiggyVestModule", (m) => {

  const web3PiggyVest = m.contract("Web3PiggyVest");

  return { web3PiggyVest };
});
