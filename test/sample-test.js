const { expect } = require("chai");
const { ethers } = require("hardhat");

const tokens = require('../tokens.json');
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

function hashToken(tokenId, account) {
  return Buffer.from(
    ethers.utils.solidityKeccak256(['uint256', 'address'], [tokenId, account]).slice(2),
    'hex',
  );
}

describe("Eggie", function () {
  it("Should return the new greeting once it's changed", async function () {
    const [owner, addr1] = await ethers.getSigners();
    this.merkleTree = new MerkleTree(Object.entries(tokens).map(token => hashToken(...token)), keccak256, { sortPairs: true });

    const Eggie = await ethers.getContractFactory("Eggie");
    const contract = await Eggie.deploy(this.merkleTree);
    await contract.deployed();

    const hash = await contract._hash(owner.address, 123)
    console.log(hash);
  });
});
