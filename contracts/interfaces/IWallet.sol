// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

interface IWallet {

	function initializeRouter(address router) external;

	function removeRouter(address router) external;

	function isWhitelisted(address router) external view returns (bool);
}