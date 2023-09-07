// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ISoilSensors.sol";

contract BrownfieldERC721Token is ERC721URIStorage {
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

    constructor(
        address _sensors,
        uint256 _supply,
        uint256 _mintInterval,
        uint256 _minPH,
        uint256 _maxPH
    ) ERC721("Brownfield Tokenization Prototype ERC721", "BTP_ERC721") {
        sensors = _sensors;
        initialSupply = _supply;
        numMinted = 0;
        mintInterval = _mintInterval;
        minPH = _minPH;
        maxPH = _maxPH;
        lastMinted = block.timestamp; // in seconds
        owner = msg.sender;
        _mint(owner, _supply);
    }

    function mint(string memory tokenURI) external returns (uint256) {
        require(msg.sender == owner, "Only the owner can call this function");
        require(
            SafeMath.sub(block.timestamp, lastMinted) >= mintInterval,
            "Not enough time has passed since last minting"
        );

        // get the soil pollution and pH levels
        uint256 curr_benzoApyrene = ISoilSensors(sensors).readBenzoApyrene();
        uint256 curr_arsenic = ISoilSensors(sensors).readArsenic();
        pH = ISoilSensors(sensors).readPH();
        require(
            curr_benzoApyrene <= benzoApyrene &&
                curr_arsenic <= arsenic &&
                pH >= minPH &&
                pH <= maxPH,
            "Soil pollution levels have not decreased, no token can me minted!"
        );

        uint256 newItemId = numMinted;
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        lastMinted = block.timestamp;
        ++numMinted; // ++i saves gas vs i++
        benzoApyrene = curr_benzoApyrene;
        arsenic = curr_arsenic;
        return newItemId;
    }

    function getNumMinted() public view returns (uint256) {
        return numMinted;
    }
}
