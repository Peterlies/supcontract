// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FireLock.sol";

contract FireLockFactory is Ownable{

    address  currentLock;
    address[] public lockList;
    address public weth;
    uint256 fee;
    bool public feeon;
    mapping(address => address )  currentLockAddress;
    mapping(address => address[]) public ownerLock; 
    constructor(address _weth){
    weth = _weth;
    }
    function setFeeOn(bool _feeon)public onlyOwner{
        feeon = _feeon;
    }
    function setFee(uint256 _fee)public onlyOwner{
        require(feeon == true,'fee not turn on');
        fee = _fee;

    }
    function createLock() public { 
        currentLock = address(new FireLock(weth,fee,feeon));
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