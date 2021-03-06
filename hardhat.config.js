require("@nomiclabs/hardhat-waffle");
const dotenv = require('dotenv');
dotenv.config();
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const ALCHEMY_PRIVATE_KEY = process.env.ALCHEMY_PRIVATE_KEY;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    ropsten: {
      url: `https://eth-ropsten.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [`${ALCHEMY_PRIVATE_KEY}`]
    },
    mumbai: {
      url: `https://polygon-mumbai.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [`${ALCHEMY_PRIVATE_KEY}`]
    },
    polygon: {
      url: `https://polygon-mainnet.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [`${ALCHEMY_PRIVATE_KEY}`]
    }
  },
};
