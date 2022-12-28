// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapV2Router02.sol";

interface ICityNode{
    function checkTotalReputationPointsExternal(address user)external view returns(uint256);
}

contract MinistryOfFinance is Ownable {

    uint256 public intervalTime;

    address[] public AllocationFundAddress;
    
    uint[] public distributionRatio;

    bool public pause;
    address public controlAddress;
    address public cityNodeAddress;
    address public GovernanceAddress;
    mapping(address => uint256) public AllocationFundUserTime;


    IUniswapV2Router02 public uniswapV2Router;

    constructor() {
        //mainnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
    }
    function setCityNodeAddress(address _cityNodeAddress) public onlyOwner {
        cityNodeAddress = _cityNodeAddress;
    }
    function setDistributionRatio(uint i, uint rate) public onlyOwner{
        distributionRatio[i] = rate;
    }
    
    function setDistributionRatioExternal(uint i, uint rate) external {
        require(msg.sender == GovernanceAddress,"callback Address is error");
        distributionRatio[i] = rate;
    }

    function setControlAddress(address _controlAddress) public onlyOwner{
        controlAddress = _controlAddress;
    }
    function setGovernanceAddress(address _GovernanceAddress) public onlyOwner{
        GovernanceAddress = _GovernanceAddress;
    }
    function setStatus() external {
        require(msg.sender == controlAddress,"the callback address is error");
        pause = !pause;
    }

    function addAllocationFundAddress(address[] memory assigned) public onlyOwner {
        for(uint i = 0 ; i<AllocationFundAddress.length ; i++){
            AllocationFundAddress[i] = assigned[i];
        }
    }

    function addAllocationFundAddressExternal(address[] memory assigned) external {
        require(msg.sender == GovernanceAddress, "callback Address is error");
        for(uint i = 0 ; i<AllocationFundAddress.length ; i++){
            AllocationFundAddress[i] = assigned[i];
        }
    }

    function AllocationFund() public {
        require(!pause, "contract is pause");
        require(ICityNode(cityNodeAddress).checkTotalReputationPointsExternal(msg.sender) > 100000*10*18 ,"Reputation Points is not enough");
        require( block.timestamp > intervalTime + 1800,"AllocationFund need interval 30 minute");
        require( block.timestamp >  AllocationFundUserTime[msg.sender] + 43200 ,"wallet need 12 hours to callback that");
        for(uint i = 0 ; i < AllocationFundAddress.length; i ++){
        IERC20(uniswapV2Router.WETH()).transfer(AllocationFundAddress[i],distributionRatio[i]/100);
        }
        intervalTime = block.timestamp;
        AllocationFundUserTime[msg.sender] = block.timestamp;
        IERC20(uniswapV2Router.WETH()).transfer(msg.sender, 5 * 10**16);
    }


}