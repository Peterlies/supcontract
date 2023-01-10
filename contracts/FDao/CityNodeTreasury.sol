// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapV2Router02.sol";
contract CityNodeTreasury  {
    address[] public AllocationFundAddress;
    uint[] public rate;
    IUniswapV2Router02 public uniswapV2Router;
    address public admin;
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
    //0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 pancake
    //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D uniswap
    constructor(address _admin) {
        admin = _admin;
        //mainnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
    }
    function setAllocationRate(uint[] memory _rate) public onlyAdmin{
        rate = _rate;
    }
    function addAllocationFundAddress(address[] memory assigned) public onlyAdmin {
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