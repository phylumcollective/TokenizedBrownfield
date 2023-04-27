// SPDX-License-Identifier: MIT
pragma solidity ^0.18.0;

import "./ISoilSensors.sol";

contract SoilSensors is ISoilSensors {
    uint256 private benzoApyrene;
    uint256 private arsenic;
    uint256 private pH;
    uint256 private power;
    mapping(string => uint256) private sensors;
    address private oracle;
    address private immutable owner;

    constructor(
        uint256 initialBenzoApyrene,
        uint256 initialArsenic,
        uint256 initialPH,
        uint256 initialPower,
        address oracle_
    ) {
        benzoApyrene = initialBenzoApyrene;
        arsenic = initialArsenic;
        pH = initialPH;
        power = initialPower;
        sensors["benzoApyrene"] = benzoApyrene;
        sensors["arsenic"] = arsenic;
        sensors["pH"] = pH;
        sensors["power"] = power;
        oracle = oracle_;
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

    function readPower() external view override returns (uint256) {
        return power;
    }

    function readSensors()
        external
        view
        override
        returns (mapping(string => uint256))
    {
        return sensors;
    }

    function setBenzoApyrene(uint256 benzoApyrene_) external {
        require(msg.sender == oracle, "Only oracle can call this function");
        benzoApyrene = benzoApyrene_;
        sensors["benzoApyrene"] = benzoApyrene;
    }

    function setArsenic(uint256 arsenic_) external {
        require(msg.sender == oracle, "Only oracle can call this function");
        arsenic = arsenic_;
        sensors["arsenic"] = arsenic;
    }

    function setPH(uint256 pH_) external {
        require(msg.sender == oracle, "Only oracle can call this function");
        pH = pH_;
        sensors["pH"] = pH;
    }

    function setPower(uint256 power_) external {
        require(msg.sender == oracle, "Only oracle can call this function");
        power = power_;
        sensors["power"] = power;
    }

    function updateOracle(address oracle_) external {
        require(msg.sender == owner, "Only owner can update oracle address");
        oracle = oracle_;
    }
}
