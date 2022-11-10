// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {IAddressesProvider} from "./interfaces/IAddressesProvider.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract AddressesProvider is Ownable, IAddressesProvider {

    event NewWalletDeployer(address indexed newWalletDeployer, address indexed oldWalletDeployer);
    event NewModulesHub(address indexed newModulesHub, address indexed oldModulesHub);
    event NewRoutersHub(address indexed newRoutersHub, address indexed oldRoutersHub);
    event NewHub(address indexed newHub, address indexed oldHub);
    event NewLensProvider(address indexed newLensProvider, address indexed oldLensProvider);

    mapping(bytes32 => address) private _addresses;

    bytes32 private constant WALLET_DEPLOYER = 'WALLET_DEPLOYER';
    bytes32 private constant MODULES_HUB = 'MODULES_HUB';
    bytes32 private constant ROUTERS_HUB  = 'ROUTERS_HUB';
    bytes32 private constant HUB  = 'HUB';
    bytes32 private constant LENS_PROVIDER  = 'LENS_PROVIDER';

    function getAddress(bytes32 id) public view override returns (address) {
        return _addresses[id];
    }

    function getWalletDeployer() external view override returns (address) {
        return getAddress(WALLET_DEPLOYER);
    }

    function setWalletDeployer(address newWalletDeployer) external override onlyOwner {
        address oldWalletDeployer = _addresses[WALLET_DEPLOYER];
        _addresses[WALLET_DEPLOYER] = newWalletDeployer;
        emit NewWalletDeployer(oldWalletDeployer, newWalletDeployer);
    }

    function getModulesHub() external view override returns (address) {
        return getAddress(MODULES_HUB);
    }

    function setModulesHub(address newModulesHub) external override onlyOwner {
        address oldModulesHub = _addresses[MODULES_HUB];
        _addresses[MODULES_HUB] = newModulesHub;
        emit NewModulesHub(oldModulesHub, newModulesHub);
    }

    function getHub() external view override returns (address) {
        return getAddress(HUB);
    }

    function setHub(address newHub) external override onlyOwner {
        address oldHub = _addresses[HUB];
        _addresses[HUB] = newHub;
        emit NewHub(oldHub, newHub);
    }

    function getRoutersHub() external view override returns (address) {
        return getAddress(ROUTERS_HUB);
    }

    function setRoutersHub(address newRoutersHub) external override onlyOwner {
        address oldRoutersHub = _addresses[ROUTERS_HUB];
        _addresses[ROUTERS_HUB] = newRoutersHub;
        emit NewRoutersHub(oldRoutersHub, newRoutersHub);
    }

    function getLensProvider() external view override returns (address) {
        return getAddress(LENS_PROVIDER);
    }

    function setLensProvider(address newLensProvider) external override onlyOwner {
        address oldLensProvider = _addresses[LENS_PROVIDER];
        _addresses[LENS_PROVIDER] = newLensProvider;
        emit NewLensProvider(oldLensProvider, newLensProvider);
    }

}
