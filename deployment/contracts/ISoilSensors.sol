// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ISoilSensors {
    function readBenzoApyrene() external view returns (uint256);

    function readArsenic() external view returns (uint256);

    function readPH() external view returns (uint256);

    //function readPower() external view returns (uint256);
}
