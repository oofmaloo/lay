// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Wallet} from './Wallet.sol';
// import {IHub} from './interfaces/IHub.sol';
import {IAddressesProvider} from "./interfaces/IAddressesProvider.sol";
import {ILensProvider} from "../lens/LensProvider.sol";
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Hub is Ownable {

  event NewWallet(address indexed owner, address wallet, address oldWallet, uint256 when);
  event UpdateWallet(address indexed owner, address wallet, address oldWallet, uint256 when);

  address public deployer;

  // each user can have multiple wallet
  // each profile_id can have one wallet
  // if a user tranfers their profile_id they cannot access modules

  // user => count => wallet
  mapping(address => mapping(uint256 => address)) public _wallets;
  mapping(address => uint256) public walletsCount;
  // profileId => wallet
  mapping(uint256 => address) public _profileWallets;

  // user => profile_id => wallet
  // mapping(uint256 => address) public _wallets;


  // user => count => [wallet]
  // mapping(address => mapping(uint256 => address)) public depreciatedWallets;
  // user => count
  // mapping(address => uint256) public depreciatedWalletsCount;
  IAddressesProvider public _provider;

  constructor(IAddressesProvider provider) {
    _provider = provider;
  }

  function setDeployer(
      address deployer_ 
  ) external onlyOwner {
      deployer = deployer_;
  }

  // function create() public returns (address) {
  //   address user = msg.sender;
  //   if (wallets[user] != address(0)) {
  //     depreciatedWallets[user][depreciatedWalletsCount[user]] = wallets[user];
  //     depreciatedWalletsCount[user]++;
  //   }

  //   Wallet walletInstance = new Wallet(user);
  //   wallets[user] = address(walletInstance);

  //   emit NewWallet(
  //     user,
  //     address(walletInstance),
  //     depreciatedWallets[user][depreciatedWalletsCount[user]],
  //     block.timestamp
  //   );

  //   // store metadata somewhere for lens platforms to query
  //   return address(walletInstance);
  // }

  /// creating a new wallet requires
  /// caller owns the profileId
  function create(uint256 profileId) public returns (address) {
    address user = msg.sender;
    console.log("profileId", profileId);

    // if owner of lens profile is caller
    // they can create a new wallet with the profileId
    // WARNING: THIS OVERRIDES ANY OTHER WALLET THE PROFILE PREVIOUSLY WAS
    //          ATTACHED TO
    //          IF YOU WANT TO MIGRATE A NEWLY OBTAINED OR MINTED LENS PROFILE
    //          TO YOUR EXISTING LENS WALLET, USE THE UPDATE FUNCTION TO ATTACH
    //          THE PROFILE TO YOUR ALREADY EXISTING WALLET
    console.log("ILensProvider(_provider.getLensProvider()", _provider.getLensProvider());
    console.log("ILensProvider(_provider.getLensProvider()", ILensProvider(_provider.getLensProvider()).getLensHub());

    address profileOwner = IERC721(ILensProvider(_provider.getLensProvider()).getLensHub()).ownerOf(profileId);
    console.log("profileOwner", profileOwner);
    
    require(user == profileOwner, "Wallet ownership mismatch");
    // init new wallet
    Wallet walletInstance = new Wallet(user);
    // set wallet as owner
    uint256 _walletsCount = walletsCount[user];
    _wallets[user][_walletsCount] = address(walletInstance);
    walletsCount[user]++;
    console.log("_walletsCount", _walletsCount);

    address oldProfileWallet = _profileWallets[profileId];
    _profileWallets[profileId] = address(walletInstance);
    console.log("oldProfileWallet", oldProfileWallet);

    emit NewWallet(
      user,
      address(walletInstance),
      oldProfileWallet,
      block.timestamp
    );

    // store metadata somewhere for lens platforms to query
    return address(walletInstance);
  }

  /// creating a new wallet requires
  /// caller owns wallet
  /// caller owns the profileId
  function update(address wallet, uint256 profileId) public returns (address) {
    address user = msg.sender;
    require(_profileWallets[profileId] != wallet, "Wallet already owns profileId");

    // ensure wallet is owned by caller
    Wallet walletInstance = Wallet(payable(msg.sender));
    address walletOwner = walletInstance.owner();
    require(user == walletOwner, "Wallet ownership mismatch");

    // if owner of lens profile is caller
    // they can create a new wallet with the profileId
    // WARNING: THIS OVERRIDES ANY OTHER WALLET THE PROFILE PREVIOUSLY WAS
    //          ATTACHED TO
    //          THIS FUNCTION IS FOR MIGRATING A LENS PROFILE ID TO A NEW WALLET
    //          IN THE CASE OF A WALLET OWNER OBTAINS A NEW PROFILE
    address profileOwner = IERC721(ILensProvider(_provider.getLensProvider()).getLensHub()).ownerOf(profileId);
    require(user == profileOwner, "Wallet ownership mismatch");

    // update profile mapping to new wallet
    address oldProfileWallet = _profileWallets[profileId];
    _profileWallets[profileId] = wallet;

    emit UpdateWallet(
      user,
      address(walletInstance),
      oldProfileWallet,
      block.timestamp
    );

    // store metadata somewhere for lens platforms to query
    return address(walletInstance);
  }

  // createa new wallet
  function replace(uint256 profileId) public returns (address) {

  }

  function getUserWallets(
    address user
  ) external view returns (address[] memory) {
      uint256 _walletsCount = walletsCount[user];
      uint256 droppedWalletsCount = 0;
      address[] memory wallets = new address[](_walletsCount);

      for (uint256 i = 0; i < _walletsCount; i++) {
          if (_wallets[user][i] != address(0)) {
              wallets[i - droppedWalletsCount] = _wallets[user][i];
          } else {
              droppedWalletsCount++;
          }
      }

      // Reduces the length of the encoders array by `droppedWalletsCount`
      assembly {
          mstore(wallets, sub(_walletsCount, droppedWalletsCount))
      }
      return wallets;
  }

  function getWallet(
    uint256 profileId
  ) external view returns (address) {
    return _profileWallets[profileId];
  }

}
