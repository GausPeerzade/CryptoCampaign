// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const CrowdFunding = await hre.ethers.getContractFactory("CrowdFunding");
  const crowdfunding = await CrowdFunding.deploy("0xb642f6F85fc68876700FB2699963611632AD8644");

  await crowdfunding.deployed();

  console.log(
    "Your Contract is deployed on :- ", crowdfunding.address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
