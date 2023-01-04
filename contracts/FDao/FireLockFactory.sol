// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FireLock.sol";

contract FireLockFactory is Ownable{

    address  currentLock;
    address[] public lockList;
    mapping(address => address )  currentLockAddress;
    mapping(address => address[]) public ownerLock; 
    constructor(){
    }
    function createLock() public { 
        currentLock = address(new FireLock());
        ownerLock[msg.sender].push(currentLock);
        currentLockAddress[msg.sender] = currentLock;
        lockList.push(currentLock);
    }
    function getUserCurrentLock() public view returns(address) {
        return currentLockAddress[msg.sender];
    }
    function getOwnerLockLenglength() public view returns(uint256){
        return ownerLock[msg.sender].length;
    }
    function getLockList() public view returns(uint256){
        return lockList.length;
    }
}