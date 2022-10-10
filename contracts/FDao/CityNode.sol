// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract cityNode is Ownable {
    bool public contractStatus = true; 

    mapping(address => bool) public isCityNodeUser;

    mapping(uint256 => bool) public isNotLightCity;

    constructor(){

    }

    function checkIsCityNode(address account) external view returns(bool) {
        return isCityNodeUser[account];   
    }

    function setPause() public onlyOwner {
        contractStatus = !contractStatus;
    }
    function joinCityNode(address account) public {
        isCityNodeUser[account] = true;
    }
}