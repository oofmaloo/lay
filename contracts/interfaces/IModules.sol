// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

interface IModules {

	function initializeModule(uint256 _id, bytes calldata data) external;

  function isEncoder(address encoder) external view returns (bool);

  function setEncoder(address encoder) external;

  function dropEncoder(address encoder) external;

  function getEncodersList() external view returns (address[] memory);

  function process(
    address from,
    address to,
    address target,
    uint256 value,
    bytes calldata calldata_,
    string memory description
  ) external returns (uint256);

  // function execute(
  //   address router,
  //   address from,
  //   address to,
  //   address target,
  //   uint256 value,
  //   bytes calldata calldata_,
  //   bytes32 descriptionHash
  // ) external payable returns (uint256);

  function execute(
      uint256 functionId
  ) external payable returns (uint256);

}