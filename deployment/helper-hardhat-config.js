const networkConfig = {
  31337: {
    name: "localhost",
  },
  11155111: {
    name: "sepolia",
  },
};

const INITIAL_SUPPLY = "1000000000000000000000000";
const INITIAL_BENZOAPYRENE = "100";
const INITIAL_ARSENIC = "100";
const INITIAL_PH = "7";
//const INITIAL_POWER = "0";
const MIN_PH = "5";
const MAX_PH = "8";
const MINT_INTERVAL = "3600";

const developmentChains = ["hardhat", "localhost"];

module.exports = {
  networkConfig,
  developmentChains,
  INITIAL_SUPPLY,
  INITIAL_BENZOAPYRENE,
  INITIAL_ARSENIC,
  INITIAL_PH,
  //INITIAL_POWER,
  MIN_PH,
  MAX_PH,
  MINT_INTERVAL,
};
