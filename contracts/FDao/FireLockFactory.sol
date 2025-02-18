// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FireLock.sol";

contract FireLockFactory is Ownable{

    address public currentLock;
    address[] public lockList;
    address public weth;
    address public fireLockFeeAddress;
    mapping(address => address )  currentLockAddress;
    mapping(address => address[]) public ownerLock; 
    constructor(address _weth,address _fireLockFeeAddress){
    weth = _weth;
    fireLockFeeAddress = _fireLockFeeAddress;
    }
 
    function createLock() public { 
        currentLock = address(new FireLock(weth,fireLockFeeAddress));
        ownerLock[msg.sender].push(currentLock);
        currentLockAddress[msg.sender] = currentLock;
        lockList.push(currentLock);
    }
    function setfireLockFeeAddress(address _addr) public onlyOwner{
        fireLockFeeAddress = _addr;
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