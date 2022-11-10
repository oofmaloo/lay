// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;
import {ISettingsModule} from "../interfaces/ISettingsModule.sol";

contract MockPaymentsSettingsModule is ISettingsModule {

    modifier onlyModuleHub() {
        require(msg.sender == moduleHub, "Sender not hub");
        _;
    }

    modifier onlyModule() {
        require(true);
        _;
    }

    address public moduleHub;

    constructor(address _moduleHub) {
    	moduleHub = _moduleHub;
    }

    address public _module;
    bool public _initialized;

	function initializeSettingsModule(address module, bytes calldata data) external onlyModuleHub {
		require(!_initialized, 'Initialized');
		_initialized = true;
		_module = module;
	}

	function beforeProcessing(
		uint256 id,
		address from,
		address to,
		address target,
		uint256 value,
		bytes memory calldata_,
		string memory description
	) external onlyModule {

	}

	function afterProcessing(   
		uint256 id,
		address from,
		address to,
		address target,
		uint256 value,
		bytes memory calldata_,
		string memory description
	) external onlyModule {

	}

	function beforeFinalizing(
		uint256 id,
		address from,
		address to,
		address target,
		uint256 value,
		bytes memory calldata_,
		string memory description
	) external onlyModule {

	}

	function afterFinalizing(   
		uint256 id,
		address from,
		address to,
		address target,
		uint256 value,
		bytes memory calldata_,
		string memory description
	) external onlyModule {
		// revert();
  //       try foo.myFunc(_i) returns (string memory result) {
  //           emit Log(result);
  //       } catch {
  //           emit Log("external call failed");
  //       }

		// IWallet(to).executeHook(
		// 	address[] memory targets,
		// 	uint256[] memory values,
		// 	bytes[] memory calldatas,
		// 	string memory description
		// )
	}

}