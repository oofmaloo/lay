// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

interface IModulesHub {
    function initializeModule(address newModule, string memory description, bytes calldata data) external;

    function replaceModule(uint256 id, address oldModule, address newModule) external;

    function isModuleWhitelisted(address module) external view returns (bool);

    function initializeSettings(address module, address settingsModule, bytes calldata data) external;

    function getSettings(uint256 id, address wallet) external view returns (address);
}