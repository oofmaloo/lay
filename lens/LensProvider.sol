// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ILensProvider {
	function getLensHub() external view returns (address);
}

contract LensProvider is Ownable, ILensProvider {
	address internal lensHub;

	function setLensHub(address _lensHub) external onlyOwner {
		lensHub = _lensHub;
	}
	
	function getLensHub() external view override returns (address) {
		return lensHub;
	}
}