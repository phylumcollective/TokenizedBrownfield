require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("hardhat-deploy");
require("hardhat-contract-sizer");

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
/** @type import('hardhat/config').HardhatUserConfig */

const SEPOLIA_RPC_URL =
  process.env.SEPOLIA_RPC_URL ||
  "https://eth-sepolia.g.alchemy.com/v2/AMZXngQ_clTrmcFCg1b9mstpk9if3Vzg";
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "";
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || "";
const REPORT_GAS = process.env.REPORT_GAS.toLowerCase() === "true" || false;
const LOCALHOST_RPC_URL = process.env.LOCALHOST_RPC_URL;

module.exports = {
  defaultNetwork: "hardhat", // blank blockchain that gets destroyed after script/app is run
  networks: {
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 11155111,
      blockConfirmations: 6,
      saveDeployments: true,
    },
    localhost: {
      url: LOCALHOST_RPC_URL, // local hardhat blockchain node
      chainId: 31337,
      saveDeployments: true,
    },
  },
  solidity: {
    compilers: [{ version: "0.8.18" }, { version: "0.6.6" }],
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  gasReporter: {
    enabled: REPORT_GAS,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
    coinmarketcap: COINMARKETCAP_API_KEY,
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
    },
  },
  paths: {
    deploy: "deploy",
    deployments: "deployments",
  },
  /*   roles: {
    sensorsUpdater: {
      name: "SENSORS_UPDATER_ROLE",
      description: "Role for updating sensor levels",
    },
    defaultAdmin: {
      name: "DEFAULT_ADMIN_ROLE",
      description: "Role for default admin",
    },
  }, */
  contractSizer: {
    runOnCompile: false,
    only: ["BrownfieldERC20Token", "BrownfieldERC721Token", "SoilSensors"],
  },
  mocha: {
    timeout: 200000, // 200 seconds max for running tests
  },
};

// remember to use ethers ^5 (not 6):
// https://github.com/smartcontractkit/full-blockchain-solidity-course-js/discussions/5327
