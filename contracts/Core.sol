// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Wallet} from './Wallet.sol';

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Core {
    string public version = "1.0";
    address payable public owner;

    event NewWallet(address indexed owner, address indexed wallet, uint256 when);

    constructor() payable {
        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    function create(
        address[] memory routers, 
        address defaultEarner, 
        bool autoEarn_
    ) public returns (address) {
        Wallet walletInstance = new Wallet(
            routers, 
            defaultEarner, 
            autoEarn_
        );

        emit NewWallet(msg.sender, address(walletInstance), block.timestamp);

        // store metadata somewhere for lens platforms to query
        return address(walletInstance);
    }
}
