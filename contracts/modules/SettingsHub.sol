// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ISettingsHub} from "../interfaces/ISettingsHub.sol";

import "hardhat/console.sol";

/// settings contracts are whitelisted settings hooks wallets are 
/// able to install that can call before or after a function call
/// this contract simply whitelists them with no other logic
contract SettingsHub is Ownable, ISettingsHub {

    modifier onlyGov() {
        _checkGov();
        _;
    }

	constructor(){}

	mapping(address => bool) private _settings;

	// setting functions
	function initializeSettings(address setting) external override onlyOwner {
		require(setting != address(0), 'Setting is zero');
		_settings[setting] = true;
	}

	function removeSettings(address setting) external override onlyOwner {
		require(setting != address(0), 'Setting is zero');
		_settings[setting] = false;
	}

	function isWhitelisted(address setting) external view override returns (bool) {
		return _settings[setting];
	}

    /**
     * @dev Throws if the sender is not governance.
     */
    function _checkGov() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

}