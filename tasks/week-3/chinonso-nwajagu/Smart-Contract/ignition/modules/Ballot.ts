// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const BallotModule = buildModule("BallotModule", (m) => {

  const ballot = m.contract("Ballot");

  return { ballot };
});

export default BallotModule;
