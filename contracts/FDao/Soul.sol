// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Soul {
    address public owner;
    address public create;
    address[] public sbt;
    uint256[] public sbtAmount;
    constructor(address _owner, address _create) {
        owner = _owner;
        create = _create;
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    modifier onlyCreate{
        require(msg.sender == create);
        _;
    }
    function setSBTAddress(address[] memory _sbt) external onlyCreate {
        for(uint i = 0 ; i < _sbt.length; i ++) {
            sbt[i] = _sbt[i];
        }
    }
    function checkBalanceOfSBT(address _user) external returns(uint256[] memory) {
        for(uint i = 0 ; i < sbt.length ; i++) {
            sbtAmount.push(IERC20(sbt[i]).balanceOf(_user));
        }
        return sbtAmount;
    }


}