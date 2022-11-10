// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IRoutersHub} from "./interfaces/IRoutersHub.sol";

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Wallet is Ownable {

  event TransactionCreated(
    uint256 transactionId,
    address[] targets,
    uint256[] values,
    string[] signatures,
    bytes[] calldatas,
    string description
  );

  event HookCreated(
    uint256 transactionId,
    address[] targets,
    uint256[] values,
    string[] signatures,
    bytes[] calldatas,
    string description
  );

  event Deposit(address indexed sender, uint value);

  /// @dev Gives wallet owner ability to call any function
  /// Otherwise wallet can only call whitelisted encoder contracts
  bool public advancedMode;

  constructor(address owner) {
    transferOwnership(owner);
  }

  /// @dev Fallback function allows to deposit ether.
  // function()
  //   payable
  // {
  //   if (msg.value > 0)
  //     Deposit(msg.sender, msg.value);
  // }

  receive() external payable  { 
    if (msg.value > 0)
      emit Deposit(msg.sender, msg.value);

  }

  fallback() external payable {
    if (msg.value > 0)
      emit Deposit(msg.sender, msg.value);

  }

  function hashTransaction(
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory calldatas,
      bytes32 descriptionHash
  ) public pure virtual returns (uint256) {
      return uint256(keccak256(abi.encode(targets, values, calldatas, descriptionHash)));
  }

  function execute(
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    string memory description
  ) public onlyOwner payable returns (uint256) {
    // if (!advancedMode) {
    //   for (uint256 i = 0; i < targets.length; ++i) {
    //     require(IRoutersHub(_provider.getRoutersHub()).isWhitelisted(targets[i]), 
    //       "Turn on advanced mode to call non whitelisted encoders"
    //     );
    //   }
    // }
    console.log("execute");
    uint256 transactionId = hashTransaction(targets, values, calldatas, keccak256(bytes(description)));

    // FunctionCallState status = state(transactionId);

    // _functionCalls[transactionId].executed = true;

    _execute(transactionId, targets, values, calldatas, keccak256(bytes(description)));

    emit TransactionCreated(
      transactionId,
      targets,
      values,
      new string[](targets.length),
      calldatas,
      description
    );

    return transactionId;
  }

  function executeHook(
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    string memory description
  ) public payable {
    // if (!advancedMode) {

    // }

    // uint256 transactionId = hashTransaction(targets, values, calldatas, keccak256(bytes(description)));

    _execute(0, targets, values, calldatas, keccak256(bytes(description)));

    emit HookCreated(
      0,
      targets,
      values,
      new string[](targets.length),
      calldatas,
      description
    );
  }

  /**
   * @dev Internal execution mechanism. Can be overridden to implement different execution mechanism
   */
  function _execute(
      uint256, /* functionCallId */
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory calldatas,
      bytes32 /*descriptionHash*/
  ) internal {
      string memory errorMessage = "Wallet: call reverted without message";
      for (uint256 i = 0; i < targets.length; ++i) {
        // if (!advancedMode) {
        //   require(IRoutersHub(_provider.getRoutersHub()).isWhitelisted(targets[i]), 
        //     "Turn on advanced mode to call non whitelisted encoders"
        //   );
        // }
        (bool success, bytes memory returndata) = targets[i].call{value: values[i]}(calldatas[i]);
        Address.verifyCallResult(success, returndata, errorMessage);
      }
  }
}
