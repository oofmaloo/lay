// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

interface IAddressesProvider {

    function getAddress(bytes32 id) external view returns (address);

    function getWalletDeployer() external view returns (address);

    function setWalletDeployer(address newWalletDeployer) external;

    function getModulesHub() external view returns (address);

    function setModulesHub(address newModulesHub) external;

    function getHub() external view returns (address);

    function setHub(address newHub) external;

    function getRoutersHub() external view returns (address);

    function setRoutersHub(address newRoutersHub) external;

    // function getSettingsHub() external view returns (address);

    // function setSettingsHub(address newRoutersHub) external;
    
    function getLensProvider() external view returns (address);

    function setLensProvider(address newLensProvider) external;

}
