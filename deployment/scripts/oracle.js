require("dotenv").config();
const SerialPort = require("serialport");
const { ethers } = require("hardhat");
const express = require("express");

// ======= BLOCKCHAIN STUFF ======= //
// Set up connection to EVM-based network
const provider = new ethers.providers.JsonRpcProvider(
  process.env.LOCALHOST_RPC_URL
);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// Set up the contract instances
const sensorsContractAddress = process.env.SENSORS_CONTRACT_ADDRESS;
const sensorsContractABI =
  require("../artifacts/contracts/SoilSensors.sol/SoilSensors.json").abi;
const sensorsContract = new ethers.Contract(
  sensorsContractAddress,
  sensorsContractABI,
  wallet
);
const tokenContractAddress = process.env.TOKEN_CONTRACT_ADDRESS;
const tokenContractABI =
  require("../artifacts/contracts/BrownfieldERC20Token.sol/BrownfieldERC20Token.json").abi;
const tokenContract = new ethers.Contract(
  tokenContractAddress,
  tokenContractABI,
  wallet
);

// Define function to send power level data to the SoilSensors smart contract
async function sendPowerLevel(powerLevel) {
  const tx = await sensorsContract.setPower(powerLevel);
  console.log(`Transaction hash: ${tx.hash}`);
}

// ======= SERIAL PORT/ARDUINO STUFF ======= //
// get the port name from the command line
let portName = process.argv[2];
// Set up serial port connection to the Arduino
const serialPort = new SerialPort(portName, { baudRate: 9600 });
// if they didn't give a port name, tell them so, then quit:
if (!portName) {
  giveInstructions();
}

// --- these are the definitions for the serial events: --- //
myPort.on("open", () => {
  console.log("Serial port opened");
}); // called when the serial port opens

myPort.on("close", () => {
  console.log("serial port closed.");
}); // called when the serial port closes

myPort.on("error", (err) => {
  console.log(err);
}); // called when there's an error with the serial port

// Set up event listener for incoming data from Arduino
serialPort.on("data", async (data) => {
  const powerLevel = parseInt(data.toString(), 10);
  sendPowerLevel(powerLevel);

  // get the pollution levels from the SoilSensors contract
  const benzoApyrene = await sensorsContract.sensors("benzoApyrene");
  const arsenic = await sensorsContract.sensors("arsenic");
  const pH = await sensorsContract.sensors("pH");
  const numTokensMinted = await tokenContract.numMinted;
  let response = [
    benzoApyrene.toString(),
    arsenic.toString(),
    pH.toString(),
    numTokensMinted.toString(),
  ];
  // Send the response over serial
  serialPort.write(response.join(",") + "\n");
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
  const allSensors = await sensorsContract.sensors;
  // Convert mapping data to a JSON object
  const allSensorsJSON = {};
  for (const key in allSensors) {
    allSensorsJSON[key] = allSensors[key].toString();
  }
  res.send(allSensorsJSON);
});

// get all the sensor levels from the SoilSensors contract and send them back
app.post("/updateSensors", async (req, res) => {
  await sensorsContract.setBenzoApyrene(Number(req.body.benzoApyrene));
  await sensorsContract.setArsenic(Number(req.body.arsenic));
  await sensorsContract.setPH(Number(req.body.pH));
  await sensorsContract.setPower(Number(req.body.power));
  res.end();
});

const PORT_NUM = 8001;
app.listen(PORT_NUM, () => {
  console.log(`Express HTTP server running on port ${PORT_NUM}`);
});
