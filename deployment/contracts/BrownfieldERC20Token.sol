// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ISoilSensors.sol";

contract BrownfieldERC20Token is ERC20 {
    address private immutable owner; // the contract owner
    address private sensors; // The address of the sensors contract
    uint256 public lastMinted; // The timestamp of the last minting
    uint256 public mintInterval; // The interval between minting attempts in seconds
    uint256 private initialSupply; // The initial number of tokens available
    uint256 private numMinted; // The number of tokens minted
    uint256 public minPH; // The minimum pH level for minting
    uint256 public maxPH; // The maximum pH level for minting
    uint256 public benzoApyrene; // The benzoApyrene level (in ppm)
    uint256 public arsenic; // The arsenic level (in ppm)
    uint256 public pH; // The pH level
    ISoilSensors private soilSensors;

    constructor(
        address _sensors,
        uint256 _supply,
        uint256 _mintInterval,
        uint256 _minPH,
        uint256 _maxPH
    ) ERC20("Brownfield Tokenization Prototype ERC20", "BTP_ERC20") {
        sensors = _sensors;
        initialSupply = _supply;
        numMinted = 0;
        mintInterval = _mintInterval;
        minPH = _minPH;
        maxPH = _maxPH;
        soilSensors = ISoilSensors(sensors);
        benzoApyrene = soilSensors.readBenzoApyrene();
        arsenic = soilSensors.readArsenic();
        lastMinted = block.timestamp; // in seconds
        owner = msg.sender;
        _mint(owner, _supply);
    }

    function mint() external {
        require(msg.sender == owner, "Only the owner can call this function");
        require(
            SafeMath.sub(block.timestamp, lastMinted) >= mintInterval,
            "Not enough time has passed since last minting"
        );

        require(numMinted < initialSupply, "No more tokens can be minted!");

        // get the soil pollution and pH levels
        uint256 curr_benzoApyrene = soilSensors.readBenzoApyrene();
        uint256 curr_arsenic = soilSensors.readArsenic();
        pH = soilSensors.readPH();
        require(
            curr_benzoApyrene <= benzoApyrene &&
                curr_arsenic <= arsenic &&
                pH >= minPH &&
                pH <= maxPH,
            "Soil pollution levels have not decreased, no token can me minted!"
        );

        uint256 amount = 1;
        _mint(msg.sender, amount);
        lastMinted = block.timestamp;
        ++numMinted; // ++i saves gas vs i++
        benzoApyrene = curr_benzoApyrene;
        arsenic = curr_arsenic;
    }

    function getNumMinted() public view returns (uint256) {
        return numMinted;
    }
}
