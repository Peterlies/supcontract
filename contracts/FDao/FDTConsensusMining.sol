// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFireSeed{
    function upclass(address usr) external view returns(address);
}
interface IFireSoul{
    function checkFID(address user) external view returns(bool);
}

contract FDTConsensusMining is Ownable {
    address public USDT;
    address public FDT;
    uint256 public price = 1;
    uint256 public eachRound;

    address public FireSeedAddress;
    address public FireSoulAddress;
    
    
    constructor() {

    }
    function setUSDTAddress(address _USDT) public  onlyOwner{
        USDT = _USDT;
    }
    function setFDTAddress(address _FDT) public onlyOwner{
        FDT = _FDT;
    }
    function setFireSeedAddress(address _FireSeedAddress) public  onlyOwner {
        FireSeedAddress = _FireSeedAddress;
    }
    function setFireSoulAddress(address _FireSoulAddress) public onlyOwner {
        FireSoulAddress = _FireSoulAddress;
    }


    function ConsensusMining(uint256 amount) public {


        if(eachRound + amount > 500000*10**18){
        uint256 amountRemaining = 500000*10**18 - eachRound;
        uint256 netxRounds = amount - amountRemaining;

        IERC20(USDT).transfer(address(this), amountRemaining*price/100000);
        IERC20(USDT).transfer(address(this), netxRounds*(price+1)/100000);
        IERC20(FDT).transfer(msg.sender, amountRemaining);
        IERC20(FDT).transfer(msg.sender, netxRounds);

        eachRound = netxRounds;
        price++;
        }else if(eachRound + amount == 500000*10**18){
        IERC20(USDT).transfer(address(this), amount*price/100000);
        IERC20(FDT).transfer(msg.sender, amount);
        eachRound =0;
        price++;
        }else{
        IERC20(USDT).transfer(address(this), amount*price/100000);
        IERC20(FDT).transfer(msg.sender, amount);
        eachRound = eachRound + amount;
        }
    }

}