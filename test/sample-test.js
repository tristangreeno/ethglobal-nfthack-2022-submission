const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Eggie", function () {
  it("Should return the new greeting once it's changed", async function () {
    const [owner, addr1] = await ethers.getSigners();

    const Eggie = await ethers.getContractFactory("Eggie");
    const contract = await Eggie.deploy();
    await contract.deployed();

    const hash = await contract._hash(owner.address, 123)
    console.log(hash);
  });
});
