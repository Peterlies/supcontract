// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FireLock.sol";

contract FireLockFactory is Ownable{

    address public currentLockAddress;
    mapping(address => address[]) public ownerLock; 
    constructor(){

    }
    function createLock() public { 
        currentLockAddress = address(new FireLock());
        ownerLock[msg.sender].push(currentLockAddress);
    }

}