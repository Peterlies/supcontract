// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapV2Router02.sol";

contract CityNodeTreasury is Ownable {

    address[] public AllocationFundAddress;
    uint[] public rate;

    IUniswapV2Router02 public uniswapV2Router;

    constructor() {
        //mainnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
    }
    function setAllocationRate(uint[] memory _rate) public onlyOwner{
        rate = _rate;
    }

    function addAllocationFundAddress(address[] memory assigned) public onlyOwner {
        for(uint i = 0 ; i < assigned.length ; i++){
            AllocationFundAddress[i] = assigned[i];
        }
    }

    function AllocationAmount() public {
        for(uint i = 0 ; i < AllocationFundAddress.length;i++){
            IERC20(uniswapV2Router.WETH()).transfer(AllocationFundAddress[i],rate[i]);
        }
    }


}