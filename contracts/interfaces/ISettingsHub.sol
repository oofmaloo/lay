// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

interface ISettingsHub {

	function initializeSettings(address setting) external;

	function removeSettings(address setting) external;

	function isWhitelisted(address setting) external view returns (bool);
}