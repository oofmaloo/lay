// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IRoutersHub} from "../interfaces/IRoutersHub.sol";

import "hardhat/console.sol";

/// routers are whitelisted calls wallets are 
/// able to make and routers are able to accept from
contract RoutersHub is Ownable, IRoutersHub {

    modifier onlyGov() {
        _checkGov();
        _;
    }

	constructor(){}

	mapping(address => bool) private _routers;

	// router functions
	function initializeRouter(address router) external override onlyOwner {
		require(router != address(0), 'Router is zero');
		_routers[router] = true;
	}

	function removeRouter(address router) external override onlyOwner {
		require(router != address(0), 'Router is zero');
		_routers[router] = false;
	}

	function isWhitelisted(address router) external view override returns (bool) {
		console.log("isWhitelisted", router);
		return _routers[router];
	}

    /**
     * @dev Throws if the sender is not governance.
     */
    function _checkGov() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

}