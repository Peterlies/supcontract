// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapV2Router02.sol";
import "./interface/IReputation.sol";


contract MinistryOfFinance is Ownable {
    uint256 public intervalTime;
    address[] public AllocationFundAddress;
    uint[] public distributionRatio;
    bool public pause;
    address public controlAddress;
    address public Reputation;
    address public GovernanceAddress;
    address public firePassport;
    mapping(address => uint256) public AllocationFundUserTime;
    mapping(uint => uint256[]) sourceOfIncome;
    IUniswapV2Router02 public uniswapV2Router;
    constructor() {
        //mainnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
    }
    //onlyOwner
    function setFirePassport(address _firePassport) public onlyOwner {
        firePassport = _firePassport;
    }
    function setReputation(address _Reputation) public onlyOwner {
        Reputation = _Reputation;
    }
    function setDistributionRatio(uint i, uint rate) public onlyOwner{
        distributionRatio[i] = rate;
    }
    function setControlAddress(address _controlAddress) public onlyOwner{
        controlAddress = _controlAddress;
    }
    
    function setGovernanceAddress(address _GovernanceAddress) public onlyOwner{
        GovernanceAddress = _GovernanceAddress;
    }
    
    function addAllocationFundAddress(address[] memory assigned) public onlyOwner {
        for(uint i = 0 ; i<AllocationFundAddress.length ; i++){
            AllocationFundAddress[i] = assigned[i];
        }
    }
    //getSource
    function setSourceOfIncome(uint num, uint256 amount) external {
        require(msg.sender == firePassport);
        sourceOfIncome[num].push(amount);
    }
    function getSourceOfIncomeLength(uint num) public view returns(uint256){
        return sourceOfIncome[num].length;
    }
    function getSourceOfIncome(uint num) public view returns(uint256[] memory){
        return sourceOfIncome[num];
    }
    //main
    function setDistributionRatioExternal(uint i, uint rate) external {
        require(msg.sender == GovernanceAddress,"callback Address is error");
        distributionRatio[i] = rate;
    }
    function setStatus() external {
        require(msg.sender == controlAddress,"the callback address is error");
        pause = !pause;
    }

    function addAllocationFundAddressExternal(address[] memory assigned) external {
        require(msg.sender == GovernanceAddress, "callback Address is error");
        for(uint i = 0 ; i<AllocationFundAddress.length ; i++){
            AllocationFundAddress[i] = assigned[i];
        }
    }
    function AllocationFund() public {
        require(!pause, "contract is pause");
        require(IReputation(Reputation).checkReputation(msg.sender) > 100000*10*18 ,"Reputation Points is not enough");
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