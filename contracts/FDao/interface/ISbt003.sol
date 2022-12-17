// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface ISbt003 {
	function mint(address account, uint256 amount) external;
	function burn(address account, uint256 amount) external;
}
