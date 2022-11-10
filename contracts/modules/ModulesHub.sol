// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ISettingsModule} from "../interfaces/ISettingsModule.sol";
import {IModulesHub} from "../interfaces/IModulesHub.sol";
import {IModules} from "../interfaces/IModules.sol";
import {ISettingsModule} from "../interfaces/ISettingsModule.sol";

import "hardhat/console.sol";

contract ModulesHub is Ownable, IModulesHub {

    modifier onlyGov() {
        _checkGov();
        _;
    }

	constructor(){}


	// all mappings for modules are id based to allow for depreciation
	// user settings will stay intact through ids
	// For Example: the Payments Module can be replaced and the old id mapping
	// will be overriden with the new location, therefor any user settings are still functionable
	// id => contract
	// each module id is a unique type of module, such as Payments or Requests
	struct ModuleData {
		uint8 id;
		string description;
		bool active;
	}

	mapping(address => ModuleData) private _modules;
	mapping(uint256 => address) private _modulesList;
	uint256 private modulesCount;
	// module_id => module_settings
	mapping(uint256 => mapping(address => address)) private _walletModuleSettings;
	// custom settings contract per user
	mapping(uint256 => mapping(address => address)) private _customWalletModuleSettings;

	// module functions
	function initializeModule(address newModule, string memory description, bytes calldata data) external onlyOwner {
		require(newModule != address(0), 'Module is zero');
		uint256 _modulesCount = modulesCount;
		ModuleData storage module = _modules[newModule];
		module.description = description;
		module.active = true;
		modulesCount++;
		_modulesList[modulesCount] = newModule;
		IModules(newModule).initializeModule(modulesCount, data);
	}

	function replaceModule(uint256 id, address oldModule, address newModule) external onlyOwner {
		require(newModule != address(0), 'Module is zero');
		require(_modulesList[id] == oldModule, 'Module does not exist');
		_modulesList[id] = newModule;
	}

	function isModuleWhitelisted(address module) external view override returns (bool) {
		return _modules[module].active;
	}

	// settings functions

	/**
	* @notice Initialize a users custom settings.
	* This function will override previous settings
	* @param module The module the settings is attached to
	* @param settingsModule The addresses of settings contract
	* @param data Additional params for initialization
	*/
	function initializeSettings(address module, address settingsModule, bytes calldata data) external {
		ModuleData storage module = _modules[module];
		require(module.id != 0, 'Module not initialized');
		_walletModuleSettings[module.id][_msgSender()] = settingsModule;
		ISettingsModule(settingsModule).initializeSettingsModule(
			address(this), 
			data
		);
	}

	function getSettings(uint256 id, address wallet) external view returns (address) {
		return _customWalletModuleSettings[id][wallet] != address(0) ? 
		_customWalletModuleSettings[id][wallet] : 
		_walletModuleSettings[id][wallet];
		// return _walletModuleSettings[id][wallet];
	}


    /**
     * @dev Throws if the sender is not governance.
     */
    function _checkGov() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

}