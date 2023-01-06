// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IcityNode{
  function checkIsCityNode(address account , uint256 amount) external  returns(bool) ;
}