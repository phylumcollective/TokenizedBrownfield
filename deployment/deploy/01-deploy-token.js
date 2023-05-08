const { network } = require("hardhat");
const {
  networkConfig,
  developmentChains,
  INITIAL_SUPPLY,
  INITIAL_BENZOAPYRENE,
  INITIAL_ARSENIC,
  INITIAL_PH,
  INITIAL_POWER,
  MIN_PH,
  MAX_PH,
  MINT_INTERVAL,
} = require("../helper-hardhat-config");
const { verify } = require("../helper-functions");
require("dotenv").config();

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  const roles = {
    sensorsUpdater: await hre.ethers.getNamedSigners("sensorsUpdater"),
    defaultAdmin: await hre.ethers.getNamedSigners("defaultAdmin"),
  };

  const SoilSensors = await deploy("SoilSensors", {
    from: deployer,
    args: [
      INITIAL_BENZOAPYRENE,
      INITIAL_ARSENIC,
      INITIAL_PH,
      INITIAL_POWER,
      roles.sensorsUpdater.address,
      roles.defaultAdmin.address,
    ],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  log(`SoilSensors deployed at ${SoilSensors.address}`);

  const brownfieldERC20Token = await deploy("BrownfieldERC20Token", {
    from: deployer,
    args: [SoilSensors.address, INITIAL_SUPPLY, MINT_INTERVAL, MIN_PH, MAX_PH],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  log(`BrownfieldERC20Token deployed at ${brownfieldERC20Token.address}`);

  // if not running on a development chain, verify
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(SoilSensors.address, [
      INITIAL_BENZOAPYRENE,
      INITIAL_ARSENIC,
      INITIAL_PH,
      INITIAL_POWER,
      roles.sensorsUpdater.address,
      roles.defaultAdmin.address,
    ]);
    await verify(brownfieldERC20Token.address, [
      SoilSensors.address,
      INITIAL_SUPPLY,
      MINT_INTERVAL,
      MIN_PH,
      MAX_PH,
    ]);
  }
};

module.exports.tags = ["all", "token", "sensors"];
