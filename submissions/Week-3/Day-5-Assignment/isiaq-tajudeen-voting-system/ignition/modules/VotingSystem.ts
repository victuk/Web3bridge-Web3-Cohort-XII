// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const VotingSystemModule = buildModule("VotingSystemModule", (m) => {

  const votingSystem = m.contract("VotingSystem");

  return { votingSystem };
});

export default VotingSystemModule;
