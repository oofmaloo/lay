// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import {IWallet} from "../../interfaces/IWallet.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IModules} from "../../interfaces/IModules.sol";
import {IAddressesProvider} from "../../interfaces/IAddressesProvider.sol";
import {ILensProvider} from "../../../lens/LensProvider.sol";
import "../../Wallet.sol";
import "hardhat/console.sol";
import {IModulesHub} from "../../interfaces/IModulesHub.sol";

/// we do permissions checks in routers in order to allow 
/// wallet owners to migrate on lens handles burns or transfers
contract ERC20Payments {
    using SafeERC20 for IERC20;

    IAddressesProvider internal _provider;

    constructor(IAddressesProvider provider) {
        _provider = provider;
    }


    function _getLensProvider() internal returns (ILensProvider) {
        return ILensProvider(_provider.getLensProvider());
    }

    function _isWalletEligable(
        uint256 onBehalfOfProfileId,
        uint256 toProfileId,
        address to
    ) internal {
        Wallet walletFrom = Wallet(payable(msg.sender));
        address walletAccount = walletFrom.owner();
        address profileOwner = IERC721(_getLensProvider().getLensHub()).ownerOf(onBehalfOfProfileId);
        require(walletAccount == profileOwner, "Wallet ownership mismatch");

        // // is the owner of the recipient wallet still owner of the profile
        Wallet walletTo = Wallet(payable(to));
        address walletToAccount = walletTo.owner();
        address profileToOwner = IERC721(_getLensProvider().getLensHub()).ownerOf(toProfileId);
        require(walletToAccount == profileToOwner, "Wallet to ownership mismatch");
    }

    function approve(
        address account,
        address module, 
        address token, 
        address to, 
        uint256 amount, 
        string memory description
    ) external {
        // call aprove on behalf of wallet
        (bool success, bytes memory data) = token.delegatecall(
            abi.encodeWithSignature("approve(address,uint256)", module, amount)
        );
    }

    function transfer(
        uint256 onBehalfOfProfileId,
        address module, 
        address token, 
        uint256 toProfileId,
        address to, 
        uint256 amount, 
        string memory description
    ) external  {
        // is the owner of the wallet still owner of the profile
        // address payable msg_sender = address(uint160(msg.sender));

        _isWalletEligable(
            onBehalfOfProfileId,
            toProfileId,
            to
        );

        // send funds to module from wallet
        IERC20(token).safeTransferFrom(msg.sender, module, amount);
        // send funds from module to `to`
        bytes memory calldata_ = abi.encodeWithSignature("transfer(address,uint256)", to, amount);

        require(IModulesHub(_provider.getModulesHub()).isModuleWhitelisted(module), "Module not activated");

        // initiate new payment
        IModules(module).process(
            msg.sender, //lens wallet
            to, //lens wallet
            token,
            0,
            calldata_,
            description
        );
    }
}
