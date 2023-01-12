// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapV2Router02.sol";
import "./interface/IReputation.sol";


contract MinistryOfFinance is Ownable,Initializable,UUPSUpgradeable {
    uint256 public intervalTime;
    address[] public AllocationFundAddress;
    uint[] public distributionRatio;
    uint private rate;
    uint private userTime;
    bool public pause;
    address[] public callSource;
    address public opensea;
    address public controlAddress;
    address public Reputation;
    uint256 public ReputationAmount;
    address public GovernanceAddress;
    address public firePassport;
    address public fireDaoToken;
    address public warp;
    mapping(address => uint256) public AllocationFundUserTime;
    mapping(uint =>mapping(uint => uint256[])) sourceOfIncome;
    mapping(uint => address) public tokenList;
    IUniswapV2Router02 public uniswapV2Router;
    //0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 pancake
    //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D uniswap
    constructor() {
        //mainnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        setUerIntverTime(43200);
    }
    function initialize() initializer public {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        setUerIntverTime(43200);
    }
    function _authorizeUpgrade(address) internal override onlyOwner {}
    //onlyOwner
    function setUerIntverTime(uint256 _time) public onlyOwner{
        userTime = _time;
    }
    function setTotalDistributionRatio(uint _rate) public onlyOwner{
        rate = _rate;
    }
    function removeItemOfAddr(uint num) public onlyOwner{
        require(num < AllocationFundAddress.length ,'input error');
        AllocationFundAddress[num] = AllocationFundAddress[AllocationFundAddress.length - 1];
        AllocationFundAddress.pop();
    }
    function removeItemOfRate(uint num) public onlyOwner{
        require(num < distributionRatio.length,'input error');
        distributionRatio[num] = distributionRatio[distributionRatio.length - 1];
        distributionRatio.pop();
    }
    function setTokenList(uint tokenNum, address tokenAddr)public onlyOwner {
        require(tokenNum < 10,"input error");
        tokenList[tokenNum] = tokenAddr;
    }
    function setWarp(address _warp) public onlyOwner{
        warp = _warp;
    }
    function setopensea(address _opensea) public onlyOwner{
        opensea = _opensea;
    }
    function setFireDaoToken(address _fireDaoToken) public onlyOwner{
        fireDaoToken = _fireDaoToken;
    }
    function setFirePassport(address _firePassport) public onlyOwner {
        firePassport = _firePassport;
    }
    function setReputation(address _Reputation) public onlyOwner {
        Reputation = _Reputation;
    }
    function setDistributionRatio(uint i, uint _rate) public onlyOwner{
        distributionRatio[i] = _rate;
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
    function withdraw() public onlyOwner {
        IERC20(uniswapV2Router.WETH()).transfer(msg.sender , getWETHBalance());
    }
    //getSource
    function setSourceOfIncome(uint num,uint tokenNum,uint256 amount) external {
        require(msg.sender == warp ||
        msg.sender == firePassport ||
        msg.sender == fireDaoToken || 
        msg.sender == opensea);
        sourceOfIncome[num][tokenNum].push(amount);
    }

    function getSourceOfIncomeLength(uint num,uint tokenNum) public view returns(uint256){
        return sourceOfIncome[num][tokenNum].length;
    }
    function getSourceOfIncome(uint num , uint tokenNum) public view returns(uint256[] memory){
        return sourceOfIncome[num][tokenNum];
    }
    function getWETHBalance() public view returns(uint256){
        return IERC20(uniswapV2Router.WETH()).balanceOf(address(this));
    }
    //main
  
    function setDistributionRatioExternal(uint i, uint _rate) external {
        require(msg.sender == GovernanceAddress || msg.sender == owner(),"callback Address is error");
        distributionRatio[i] = _rate;
    }
    function addAllocationFundAddressExternal(address assigned) external {
        require(msg.sender == GovernanceAddress || msg.sender == owner(), "callback Address is error");
        AllocationFundAddress.push(assigned);
    }
    function setStatus() external onlyProxy() {
        require(msg.sender == controlAddress || msg.sender == owner(),"the callback address is error");
        pause = !pause;
    }
    function setReputationAmount(uint256 _amount) public onlyOwner{
        ReputationAmount = _amount; 
    }
    
    function AllocationFund(uint _tokenNum) public onlyProxy() {
        require(!pause, "contract is pause");
        require(checkRate() == 100,'rate error');
        require(IReputation(Reputation).checkReputation(msg.sender) > ReputationAmount*10*18 || msg.sender ==owner() ,"Reputation Points is not enough");
        require( block.timestamp > intervalTime + 3600,"AllocationFund need interval 30 minute");
        require( block.timestamp >  AllocationFundUserTime[msg.sender] + userTime ,"wallet need 12 hours to callback that");
        require(getWETHBalance() > 0, "the balance of WETH is error");
        if(_tokenNum == 1) {
        for(uint i = 0 ; i < AllocationFundAddress.length; i ++){
        IERC20(uniswapV2Router.WETH()).transfer(AllocationFundAddress[i],IERC20(uniswapV2Router.WETH()).balanceOf(address(this))*rate*distributionRatio[i]/100);
        }
    }else{
        for(uint i = 0 ; i < AllocationFundAddress.length; i ++){
        IERC20(tokenList[_tokenNum]).transfer(AllocationFundAddress[i],IERC20(tokenList[_tokenNum]).balanceOf(address(this))*rate*distributionRatio[i]/100);
    }
    }
        intervalTime = block.timestamp;
        AllocationFundUserTime[msg.sender] = block.timestamp;
        IERC20(uniswapV2Router.WETH()).transfer(msg.sender, 5 * 10**16);
    }
    function checkRate() public view returns(uint256){
        uint256 num;
        for(uint i = 0; i < distributionRatio.length;i++){
            num += distributionRatio[i];
        }
        return num;
    }
    function getTokenBalance(uint num) public view returns(uint256) {
        return IERC20(tokenList[num]).balanceOf(address(this));
    }
}