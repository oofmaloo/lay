// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IModules} from "../interfaces/IModules.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IModulesHub} from "../interfaces/IModulesHub.sol";
import {ISettingsModule} from "../interfaces/ISettingsModule.sol";
import {IRoutersHub} from "../interfaces/IRoutersHub.sol";
import {IAddressesProvider} from "../interfaces/IAddressesProvider.sol";

import "hardhat/console.sol";
/// Payment Module
contract PaymentsModule is Ownable, IModules {

    event DropEncoder(address indexed encoder);

    uint256 public id;

    /**
    * @dev Stores the modules hub that initialized it
    **/
    IAddressesProvider public _provider;

    constructor(IAddressesProvider provider) {
        _provider = provider;
    }

    event ModuleCallCreated(
        address from,
        address to,
        uint256 functionId,
        address encoder,
        address target,
        uint256 value,
        string description
    );

    struct FunctionData {
        address from;
        address to;
        uint256 functionId;
        address encoder;
        address target;
        uint256 value;
        string description;
        bool processed;
        bool finalized;
    }

    mapping(uint256 => FunctionData) private _payments;
    uint256 public paymentsCount;

    /**
    * @dev Encoder contracts that can call this module
    **/
    mapping(address => uint256) public _encoders;
    mapping(uint256 => address) public _encodersList;
    uint256 public encodersCount;

    bool public _initialized;

    /**
    * @dev Stores the modules hub that initialized it
    **/
    address public modulesHub;

    modifier onlyEncoders() {
        require(_encoders[_msgSender()] != 0, 'Caller not approved');
        _;
    }

    modifier onlyModulesHub() {
        require(modulesHub == _msgSender(), 'Caller not approved');
        _;
    }

    function initializeModule(uint256 _id, bytes calldata data) external override {
        require(!_initialized, 'Initialized');
        _initialized = true;
        require(_id != 0, "id is zero");
        console.log("_id", _id);
        id = _id;
        console.log("encodersCount1", encodersCount);
        modulesHub = _msgSender();

        encodersCount++; // eh, use id instead
    }

    function isEncoder(address encoder) external view override returns (bool) {
        return _encoders[encoder] != 0;
    }

    function setEncoder(address encoder) external override onlyOwner {
        console.log("_provider.getRoutersHub()", _provider.getRoutersHub());

        console.log("_provider.getRoutersHub()", IRoutersHub(_provider.getRoutersHub()).isWhitelisted(encoder));

        require(IRoutersHub(_provider.getRoutersHub()).isWhitelisted(encoder), "Encoder not whitelisted");
        if (_addEncoderToListInternal(encoder)) {
            encodersCount++;
        }
    }

    function _addEncoderToListInternal(address encoder) internal returns (bool) {
        // uint256 _encodersCount = encodersCount;
        bool encoderAlreadyAdded = false;
        console.log("_encodersCount", encodersCount);
        console.log("encodersCount", encodersCount);

        // make sure not to duplicate
        for (uint16 i = 0; i < encodersCount; i++) {
          if (_encodersList[i] == encoder) {
            encoderAlreadyAdded = true;
          }
        }

        require(!encoderAlreadyAdded, 'Errors.ENCODER_ALREADY_ADDED');

        // replace previously dropped encoders
        for (uint16 i = 1; i < encodersCount; i++) {
          if (_encodersList[i] == address(0)) {
            // override dropped encoder
            _encodersList[i] = encoder;
            _encoders[encoder] = i;
            console.log("return false");
            return false;
          }
        }
        console.log("return true");
        _encodersList[encodersCount] = encoder;
        _encoders[encoder] = encodersCount;
        console.log("encodersCount end", encodersCount);
        return true;
    }

    function dropEncoder(address encoder) external onlyOwner {
      require(encoder != address(0), 'Error: Zero address');

      _encodersList[_encoders[encoder]] = address(0);
      _encoders[encoder] = 0;

      emit DropEncoder(
          encoder
      );
    }

    function getEncodersList() public view returns (address[] memory) {
      uint256 encodersListCount = encodersCount;
      uint256 droppedEncodersCount = 0;
      address[] memory encodersList = new address[](encodersListCount);

      for (uint256 i = 0; i < encodersListCount; i++) {
          if (_encodersList[i] != address(0)) {
              encodersList[i - droppedEncodersCount] = _encodersList[i];
          } else {
              droppedEncodersCount++;
          }
      }

      // Reduces the length of the encoders array by `droppedEncodersCount`
      assembly {
          mstore(encodersList, sub(encodersListCount, droppedEncodersCount))
      }
      return encodersList;
    }

    function hashCall(
        uint256 block,
        address router,
        address from,
        address to,
        address target,
        uint256 value,
        bytes memory calldata_,
        bytes32 descriptionHash
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(block, from, to, target, value, calldata_, descriptionHash)));
    }

    function process(
        address from,
        address to,
        address target,
        uint256 value,
        bytes memory calldata_,
        string memory description
    ) public override onlyEncoders returns (uint256) {
        console.log("process");
        console.log("to", to);
        console.log("target", target);
        console.log("value", value);
        console.log("process");
        console.log("description", description);

        uint256 functionId = hashCall(block.timestamp, _msgSender(), from, to, target, value, calldata_, keccak256(bytes(description)));

        FunctionData storage _function = _payments[functionId];

        emit ModuleCallCreated(
            from,
            to,
            functionId,
            _msgSender(),
            target,
            value,
            description
        );

        _function.from = from;
        _function.to = to;
        _function.functionId = functionId;
        _function.encoder = _msgSender();
        _function.target = target;
        _function.value = value;
        _function.description = description;
        _function.processed = true;
        _function.finalized = true;

        _execute(
            functionId,
            target,
            value,
            calldata_,
            keccak256(bytes(description))
        );

        address settings = IModulesHub(modulesHub).getSettings(id, to);
        if (settings != address(0)) {
            ISettingsModule(settings).afterFinalizing(
                id,
                from,
                to,
                target,
                value,
                calldata_,
                description
            );
        }

        return functionId;
    }

    // function execute(
    //     address router,
    //     address from,
    //     address to,
    //     address target,
    //     uint256 value,
    //     bytes memory calldata_,
    //     bytes32 descriptionHash
    // ) public payable returns (uint256) {
    //     return 0;
    // }

    function execute(
        uint256 functionId
    ) public payable override returns (uint256) {

    }

    function _execute(
        uint256, /* functionId */
        address target,
        uint256 value,
        bytes memory calldata_,
        bytes32 /*descriptionHash*/
    ) internal {
        console.log("_execute");
        string memory errorMessage = "Payments Module: call reverted without message";
        // (bool success, bytes memory returndata) = target.delegatecall(calldata_);
        (bool success, bytes memory returndata) = target.call{value: value}(calldata_);
        // (bool success, bytes memory returndata) = targets[i].delegatecall(calldatas[i]);
        Address.verifyCallResult(success, returndata, errorMessage);
    }
}