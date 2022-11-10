// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract WalletSetter is Ownable {

  function initializeSettings(address module, address settingsModule, bytes calldata data) public {
    // IModulesHub().initializeSettings(address module, address settingsModule, bytes calldata data) 
  }
}
