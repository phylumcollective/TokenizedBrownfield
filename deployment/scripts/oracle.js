require("dotenv").config();
const { SerialPort } = require("serialport");
const { ethers } = require("hardhat");
const express = require("express");

// ======= BLOCKCHAIN STUFF ======= //
// Set up connection to EVM-based network
const provider = new ethers.providers.JsonRpcProvider(
  process.env.LOCALHOST_RPC_URL
);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// --- Set up the contract instances --- //
// sensors
const sensorsContractAddress = process.env.SENSORS_CONTRACT_ADDRESS;
const sensorsContractABI =
  require("../artifacts/contracts/SoilSensors.sol/SoilSensors.json").abi;
const sensorsContract = new ethers.Contract(
  sensorsContractAddress,
  sensorsContractABI,
  wallet
);

// ERC-20
const erc20ContractAddress = process.env.ERC20_CONTRACT_ADDRESS;
const erc20ContractABI =
  require("../artifacts/contracts/BrownfieldERC20Token.sol/BrownfieldERC20Token.json").abi;
const erc20Contract = new ethers.Contract(
  erc20ContractAddress,
  erc20ContractABI,
  wallet
);

// ERC-721 (NFT)
const erc721ContractAddress = process.env.ERC721_CONTRACT_ADDRESS;
const erc721ContractABI =
  require("../artifacts/contracts/BrownfieldERC721Token.sol/BrownfieldERC721Token.json").abi;
const erc721Contract = new ethers.Contract(
  erc721ContractAddress,
  erc721ContractABI,
  wallet
);

// Define function to send power level data to the SoilSensors smart contract
// async function sendPowerLevel(powerLevel) {
//   const tx = await sensorsContract.setPower(powerLevel);
//   console.log(`Transaction hash: ${tx.hash}`);
// }

// ======= SERIAL PORT/ARDUINO STUFF ======= //
// get the port name from the command line
//console.log(SerialPort.list());
const portName = "/dev/tty.usbmodem14701";
//let portName = process.argv[2];
// Set up serial port connection to the Arduino
const serialPort = new SerialPort({ path: portName, baudRate: 9600 });
// if they didn't give a port name, tell them so, then quit:
if (!portName) {
  giveInstructions();
}

// --- these are the definitions for the serial events: --- //
serialPort.on("open", () => {
  console.log("Serial port opened");
}); // called when the serial port opens

serialPort.on("close", () => {
  console.log("serial port closed.");
}); // called when the serial port closes

serialPort.on("error", (err) => {
  console.log(err);
}); // called when there's an error with the serial port

// Set up event listener for incoming data from Arduino
serialPort.on("data", async (data) => {
  //console.log(data.toString());
  /*   //const powerLevel = parseInt(data.toString(), 10);
  //sendPowerLevel(powerLevel);

  // get the pollution levels from the SoilSensors contract
  const benzoApyrene = await sensorsContract.sensors("benzoApyrene");
  const arsenic = await sensorsContract.sensors("arsenic");
  const pH = await sensorsContract.sensors("pH");
  const numERC20TokensMinted = await erc20Contract.getNumMinted();
  const numERC721TokensMinted = await erc721Contract.getNumMinted();
  let response = [
    benzoApyrene.toString(),
    arsenic.toString(),
    pH.toString(),
    numERC20TokensMinted.toString(),
    numERC721TokensMinted.toString(),
  ];
  // Send the response over serial
  serialPort.write(response.join(",") + "\n"); */
});

function giveInstructions() {
  //console.log('you did not give a port name');
  console.log("To run this properly, type \n");
  console.log("npx (or yarn) hardhat run path/to/this/script.js \n");
  process.exit(0);
}

// ======= HTTP SERVER STUFF ======= //
// Set up the HTTP server to process requests from the frontend
const app = express();

// use express.json() method for parsing JSON data coming to the server
app.use(express.json());

/* app.get("/", async (req, res) => {
  const balance = await contract.balanceOf(wallet.getAddress());
  res.send(`Token balance: ${balance}`);
}); */

// get all the sensor levels from the SoilSensors contract and send them back
app.get("/getSensors", async (req, res) => {
  // get the sensors data and format as JSON/dictionary
  const benzoApyrene = await sensorsContract.readBenzoApyrene();
  const arsenic = await sensorsContract.readArsenic();
  const pH = await sensorsContract.readPH();

  // need to convert to String to get a decimal repesentaion (as ethers defaults to hex)
  const allSensors = {
    benzoApyrene: benzoApyrene.toString(),
    arsenic: arsenic.toString(),
    pH: pH.toString(),
  };
  try {
    res.json(allSensors); // send json formated sensor values
  } catch (error) {
    res.status(500).send(error);
  }
});

// get all the sensor levels from the SoilSensors contract and send them back
app.post("/updateSensors", async (req, res) => {
  await sensorsContract.setBenzoApyrene(Number(req.body.benzoApyrene));
  await sensorsContract.setArsenic(Number(req.body.arsenic));
  await sensorsContract.setPH(Number(req.body.pH));
  //await sensorsContract.setPower(Number(req.body.power));
  res.end();
});

// mint a cryptocurrency token!
app.get("/mintERC20", async (req, res) => {
  try {
    await erc20Contract.mint();
  } catch (error) {
    console.log("ERC-20 minting error!");
    console.log(error);
  }
  const numERC20TokensMinted = await erc20Contract.getNumMinted();
  await serialMint(); // update Arduino
  try {
    res.send(numERC20TokensMinted.toString()); // send back the number of tokens minted
  } catch (error) {
    res.status(500).send(error);
  }
});

// mint an NFT!
app.get("/mintERC721", async (req, res) => {
  let uri = req.query.tokenURI;
  try {
    await erc721Contract.mint(uri);
  } catch (error) {
    console.log("ERC-721 minting error!");
    console.log(error);
  }
  const numERC721TokensMinted = await erc721Contract.getNumMinted();
  await serialMint(); // update Arduino
  try {
    res.send(numERC721TokensMinted.toString()); // send back the number of tokens minted
  } catch (error) {
    res.status(500).send(error);
  }
});

const PORT_NUM = 8001;
app.listen(PORT_NUM, () => {
  console.log(`Express HTTP server running on port ${PORT_NUM}`);
});

async function serialMint() {
  //const powerLevel = parseInt(data.toString(), 10);
  //sendPowerLevel(powerLevel);

  // get the pollution levels from the SoilSensors contract
  const benzoApyrene = await sensorsContract.sensors("benzoApyrene");
  const arsenic = await sensorsContract.sensors("arsenic");
  const pH = await sensorsContract.sensors("pH");
  const numERC20TokensMinted = await erc20Contract.getNumMinted();
  const numERC721TokensMinted = await erc721Contract.getNumMinted();
  let response = [
    benzoApyrene.toString(),
    arsenic.toString(),
    pH.toString(),
    numERC20TokensMinted.toString(),
    numERC721TokensMinted.toString(),
  ];
  // Send the response over serial
  serialPort.write(response.join(",") + "\n");
}
