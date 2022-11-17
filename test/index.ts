import { expect } from "chai";
import { ethers } from "hardhat";
import { PNKToken } from "../typechain-types/contracts/PNK_Token.sol/PNKToken";
import { PNK } from "../typechain-types/contracts/PNK";

let pnkAirdropContractAddress: any, pnkTokenAddress: any;
let pnkAirdropContract: PNK, pnkTokenContract: PNKToken;

const airdropValue: number = 20000000000000000000;
const salePrice = 2000;

describe("PNK Token and Airdrop Contract", function () {
  it("Should deloy the PNK token", async function () {
    const [owner] = await ethers.getSigners();
    const PNKAirdrop = await ethers.getContractFactory("PNK");
    const pnkairdrop = await PNKAirdrop.deploy();
    pnkAirdropContract = await pnkairdrop.deployed();

    pnkAirdropContractAddress = pnkairdrop.address;

    expect(await pnkAirdropContract.owner()).to.equal(owner.address);

    const PNK_TOKEN = await ethers.getContractFactory("PNKToken");
    const pnkToken = await PNK_TOKEN.deploy(pnkAirdropContractAddress);
    pnkTokenContract = await pnkToken.deployed();

    pnkTokenAddress = pnkToken.address;
  });

  it("Should set the pnk token address in the pnk airdrop contract", async function () {
    const [owner] = await ethers.getSigners();

    await pnkAirdropContract
      .connect(owner)
      .updatePnkTokenAddress(pnkTokenAddress);

    expect(await pnkAirdropContract.pnk_token()).to.equal(pnkTokenAddress);
  });

  it("Should airdrop tokens to a purchaser that purchase", async function () {
    const [, buyer, fakeReferrer] = await ethers.getSigners();
    const purchaseAmount = ethers.utils.parseUnits("0.0081", "ether");

    await pnkAirdropContract
      .connect(buyer)
      .airdrop(fakeReferrer.address, { value: purchaseAmount });

    const buyerBalance = await pnkTokenContract.balanceOf(buyer.address);
    const fakeReferrerBalance = await pnkTokenContract.balanceOf(
      fakeReferrer.address
    );

    expect(Number(buyerBalance)).to.equal(Number(airdropValue));

    expect(Number(fakeReferrerBalance)).to.equal(0);
  });

  it("Should accept >= 0.01 ether for pnk purchase", async function () {
    const [, buyer] = await ethers.getSigners();

    const purchaseAmount = ethers.utils.parseUnits("0.009", "ether");

    await pnkAirdropContract
      .connect(buyer)
      .buy(buyer.address, { value: purchaseAmount });

    const buyerBalance = await pnkTokenContract.balanceOf(buyer.address);
    const expectedBalance = 0.01 * 2000;

    expect(Number(buyerBalance)).to.be.greaterThan(expectedBalance);
  });
});
