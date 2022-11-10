// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IModules} from "../../interfaces/IModules.sol";

contract ERC721Payments {

    function safeTransferFrom(
		address module, 
    	address nft, 
    	address to, 
    	uint256 tokenId, 
    	string memory description
	) external {
        // send nft to module
        IERC721(nft).transferFrom(
            msg.sender,
            module,
            tokenId
        );
        // send nft to `to`
        bytes memory calldata_ = abi.encode("safeTransferFrom(address,uint256)", msg.sender, to, tokenId);
        // initiate new nft transfer
        IModules(module).process(
            msg.sender, //lens wallet
            to, //lens wallet
            nft,
            0,
            calldata_,
            description
        );
    }
}

