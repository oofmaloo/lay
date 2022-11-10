// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

// import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20} from "./ERC20.sol";

import "hardhat/console.sol";

interface IMintableERC20 {
  function mint(uint256 value) external returns (bool);

  function mintTo(address to, uint256 value) external returns (bool);

}
/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract MintableERC20 is ERC20, IMintableERC20 {
  uint8 private _decimals;
  // mapping(address => uint256) private _balances;

  function decimals() public view virtual override returns (uint8) {
    return _decimals;
  }

  function _setupDecimals(uint8 decimals) internal {
    _decimals = decimals;
  }

  constructor(
    string memory name,
    string memory symbol,
    uint8 decimals
  ) ERC20(name, symbol) {
    _setupDecimals(decimals);
  }

  /**
   * @dev Function to mint tokens
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(uint256 value) public override returns (bool) {
    _mint(_msgSender(), value);
    return true;
  }

  function mintTo(address to, uint256 value) public override returns (bool) {
    _mint(to, value);
    return true;
  }

  function _mint(address account, uint256 amount) internal virtual override {
    // console.log("_mint", account, amount);
    require(account != address(0), "ERC20: mint to the zero address");

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply += amount;
    _balances[account] += amount;
    // console.log("_balances[account]", _balances[account]);
    emit Transfer(address(0), account, amount);

    _afterTokenTransfer(address(0), account, amount);
  }

}
