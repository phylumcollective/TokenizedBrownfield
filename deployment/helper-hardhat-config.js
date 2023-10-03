const networkConfig = {
  31337: {
    name: "localhost",
  },
  11155111: {
    name: "sepolia",
  },
};

const INITIAL_SUPPLY_ERC20 = "1000000000000000000000000";
const INITIAL_SUPPLY_ERC721 = "164";
const INITIAL_BENZOAPYRENE = "1000"; //ppm - real value * 100 (restrict to two decimal points)
const INITIAL_ARSENIC = "1000"; //ppm - real value * 100 (restrict to two decimal points)
const INITIAL_PH = "700"; // real value * 100 (restrict to two decimal points)
//const INITIAL_POWER = "0";
const MIN_PH = "550";
const MAX_PH = "750"; // real value * 100 (restrict to two decimal points)
const MINT_INTERVAL_ERC20 = "3599"; // 3600 seconds (1 hour)
const MINT_INTERVAL_ERC721 = "3599"; // 3600 seconds (1 hour)

const developmentChains = ["hardhat", "localhost"];

module.exports = {
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
};
