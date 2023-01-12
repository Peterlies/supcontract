//	SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMinistryOfFinance {
  function AllocationFund() external;
  function setSourceOfIncome(uint num,uint tokenNum,uint256 amount) external;
}