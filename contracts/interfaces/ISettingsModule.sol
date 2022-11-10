// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

interface ISettingsModule {

	function initializeSettingsModule(address module, bytes calldata data) external;

  function beforeProcessing(
    uint256 id,
    address from,
    address to,
    address target,
    uint256 value,
    bytes memory calldata_,
    string memory description
  ) external;

  function afterProcessing(   
    uint256 id,
    address from,
    address to,
    address target,
    uint256 value,
    bytes memory calldata_,
    string memory description
  ) external;

  function beforeFinalizing(
    uint256 id,
    address from,
    address to,
    address target,
    uint256 value,
    bytes memory calldata_,
    string memory description
  ) external;

  function afterFinalizing(   
    uint256 id,
    address from,
    address to,
    address target,
    uint256 value,
    bytes memory calldata_,
    string memory description
  ) external;

}