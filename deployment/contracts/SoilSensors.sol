// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ISoilSensors.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract SoilSensors is ISoilSensors, AccessControl {
    uint256 private benzoApyrene;
    uint256 private arsenic;
    uint256 private pH;
    //uint256 private power;
    mapping(string => uint256) public sensors;
    address private immutable owner;
    bytes32 private constant SENSORS_UPDATER_ROLE =
        keccak256("SENSORS_UPDATER_ROLE");

    constructor(
        uint256 initialBenzoApyrene,
        uint256 initialArsenic,
        uint256 initialPH,
        //uint256 initialPower,
        address sensorsUpdater,
        address defaultAdmin
    ) {
        benzoApyrene = initialBenzoApyrene;
        arsenic = initialArsenic;
        pH = initialPH;
        //power = initialPower;
        sensors["benzoApyrene"] = benzoApyrene;
        sensors["arsenic"] = arsenic;
        sensors["pH"] = pH;
        //sensors["power"] = power;
        _setupRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _setupRole(SENSORS_UPDATER_ROLE, sensorsUpdater);
        owner = msg.sender;
    }

    function readBenzoApyrene() external view override returns (uint256) {
        return benzoApyrene;
    }

    function readArsenic() external view override returns (uint256) {
        return arsenic;
    }

    function readPH() external view override returns (uint256) {
        return pH;
    }

    // function readPower() external view override returns (uint256) {
    //     return power;
    // }

    function setBenzoApyrene(uint256 benzoApyrene_) external {
        require(
            hasRole(SENSORS_UPDATER_ROLE, msg.sender),
            "Caller does not have permission to update sensors!"
        );
        benzoApyrene = benzoApyrene_;
        sensors["benzoApyrene"] = benzoApyrene;
    }

    function setArsenic(uint256 arsenic_) external {
        require(
            hasRole(SENSORS_UPDATER_ROLE, msg.sender),
            "Caller does not have permission to update sensors!"
        );
        arsenic = arsenic_;
        sensors["arsenic"] = arsenic;
    }

    function setPH(uint256 pH_) external {
        require(
            hasRole(SENSORS_UPDATER_ROLE, msg.sender),
            "Caller does not have permission to update sensors!"
        );
        pH = pH_;
        sensors["pH"] = pH;
    }

    // function setPower(uint256 power_) external {
    //     require(hasRole(SENSORS_UPDATER_ROLE, msg.sender, "Caller does not have permission to update sensors!");
    //     power = power_;
    //     sensors["power"] = power;
    // }

    /*     function setSensors(mapping(string => uint256) _sensors) external {
        sensors = _sensors;
    } */
}
