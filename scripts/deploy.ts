// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import * as fs from "fs";
import path from "path";

async function main() {
  // We get the contract to deploy
  console.log("Deploying PNK... ");
  const PNK = await ethers.getContractFactory("PNK");
  const pnk = await PNK.deploy();

  await pnk.deployed();
  console.log("PNK Deployed.. 🚀");

  // Deploy PNK_Token
  console.log(`🤔 Deploying PNK Token with PNK: ${pnk.address}... `);
  const PNK_TOKEN = await ethers.getContractFactory("PNKToken");
  const pnkToken = await PNK_TOKEN.deploy(pnk.address);

  await pnkToken.deployed();
  console.log(`pnk token deployed: ${pnkToken.address}  🚀`);

  const DeploymentInfo = `
    export const PNK Contract = "${pnk.address}"
    export const PNK Token Contract = "${pnkToken.address}"
  `;

  console.log("Saving addresses to cache/bsctest_deploy.ts");
  const data = JSON.stringify(DeploymentInfo);
  fs.writeFileSync(
    path.resolve(__dirname, "../cache/bsctest_deploy.ts"),
    JSON.parse(data)
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
