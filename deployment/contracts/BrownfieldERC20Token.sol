// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ISoilSensors.sol";

contract BrownfieldERC20Token is ERC20 {
    address private immutable owner; // the contract owner
    address private sensors; // The address of the sensors contract
    uint256 public lastMinted; // The timestamp of the last minting
    uint256 public mintInterval; // The interval between mintings in seconds
    uint256 public supply; // The number of tokens available
    uint256 public minPH; // The minimum pH level for minting
    uint256 public maxPH; // The maximum pH level for minting
    uint256 public benzoApyrene; // The benzoApyrene level (in ppm)
    uint256 public arsenic; // The arsenic level (in ppm)
    uint256 public pH; // The pH level

    constructor(
        address _sensors,
        uint256 _supply,
        uint256 _mintInterval,
        uint256 _minPH,
        uint256 _maxPH
    ) ERC20("Brownfield ERC20 Token", "BT") {
        sensors = _sensors;
        supply = _supply;
        mintInterval = _mintInterval;
        minPH = _minPH;
        maxPH = _maxPH;
        lastMinted = block.timestamp;
        owner = msg.sender;
        _mint(owner, _supply);
    }

    function mint() external {
        require(msg.sender == owner, "Only the owner can call this function");
        require(
            SafeMath.sub(block.timestamp, lastMinted) >= mintInterval,
            "Not enough time has passed since last minting"
        );

        supply = totalSupply();
        require(supply > 0, "Out of tokens!");

        // get the soil pollution and pH levels
        uint256 curr_benzoApyrene = ISoilSensors(sensors).readBenzoApyrene();
        uint256 curr_arsenic = ISoilSensors(sensors).readArsenic();
        pH = ISoilSensors(sensors).readPH();
        require(
            curr_benzoApyrene < benzoApyrene &&
                curr_arsenic < arsenic &&
                pH >= minPH &&
                pH <= maxPH,
            "Soil pollution levels are outside the acceptable range!"
        );

        uint256 amount = 1 ether;
        _mint(msg.sender, amount);
        lastMinted = block.timestamp;
        benzoApyrene = curr_benzoApyrene;
        arsenic = curr_arsenic;
    }
}
