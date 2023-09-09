const { network } = require("hardhat");
const {
  networkConfig,
  developmentChains,
  INITIAL_SUPPLY_ERC20,
  INITIAL_SUPPLY_ERC721,
  INITIAL_BENZOAPYRENE,
  INITIAL_ARSENIC,
  INITIAL_PH,
  //INITIAL_POWER,
  MIN_PH,
  MAX_PH,
  MINT_INTERVAL_ERC20,
  MINT_INTERVAL_ERC721,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");
require("dotenv").config();

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  /*   const roles = {
    sensorsUpdater: await hre.ethers.getNamedSigners("sensorsUpdater"),
    defaultAdmin: await hre.ethers.getNamedSigners("defaultAdmin"),
  }; */

  const SoilSensors = await deploy("SoilSensors", {
    from: deployer,
    args: [
      INITIAL_BENZOAPYRENE,
      INITIAL_ARSENIC,
      INITIAL_PH,
      //INITIAL_POWER,
      //roles.sensorsUpdater.address,
      //roles.defaultAdmin.address,
    ],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  log(`SoilSensors deployed at ${SoilSensors.address}`);

  const brownfieldERC20Token = await deploy("BrownfieldERC20Token", {
    from: deployer,
    args: [
      SoilSensors.address,
      INITIAL_SUPPLY_ERC20,
      MINT_INTERVAL_ERC20,
      MIN_PH,
      MAX_PH,
    ],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  log(`BrownfieldERC20Token deployed at ${brownfieldERC20Token.address}`);

  const brownfieldERC721Token = await deploy("BrownfieldERC721Token", {
    from: deployer,
    args: [
      SoilSensors.address,
      INITIAL_SUPPLY_ERC721,
      MINT_INTERVAL_ERC721,
      MIN_PH,
      MAX_PH,
    ],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  log(`BrownfieldERC721Token deployed at ${brownfieldERC721Token.address}`);

  // if not running on a development chain, verify
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(SoilSensors.address, [
      INITIAL_BENZOAPYRENE,
      INITIAL_ARSENIC,
      INITIAL_PH,
      //INITIAL_POWER,
      roles.sensorsUpdater.address,
      roles.defaultAdmin.address,
    ]);
    await verify(brownfieldERC20Token.address, [
      SoilSensors.address,
      INITIAL_SUPPLY_ERC20,
      MINT_INTERVAL_ERC20,
      MIN_PH,
      MAX_PH,
    ]);
    await verify(brownfieldERC721Token.address, [
      SoilSensors.address,
      INITIAL_SUPPLY_ERC721,
      MINT_INTERVAL_ERC721,
      MIN_PH,
      MAX_PH,
    ]);
  }
};

module.exports.tags = ["all", "tokens", "sensors"];
