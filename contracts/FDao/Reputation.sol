// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ISoulAccount{
    function getSoulAccount(address _user) external view returns(address);
}

contract Reputation is Ownable
{ 
    // mapping(address => uint256) public Reputation;
    uint256[] public coefficient;
    address[] public sbt;
    address public fireSoul;
    constructor()  {}

    //onlyOwner
    function setSBTAddress(address[] memory _sbt) public onlyOwner {
        sbt = _sbt;
    }
    function setCoefficient(uint256[] memory _coefficient) public onlyOwner{
        coefficient = _coefficient;
    }
    function setFireSoulAddress(address _fireSoul) public onlyOwner {
        fireSoul = _fireSoul;
    }
    //main
    function checkReputation(address _user) public view returns(uint256) {
        uint256 ReputationPoint;
        for(uint i = 0 ; i < sbt.length; i ++) {
            ReputationPoint =  IERC20(sbt[i]).balanceOf(ISoulAccount(fireSoul).getSoulAccount(_user))*coefficient[i] +ReputationPoint ; 
        }
        return ReputationPoint;
    }

}