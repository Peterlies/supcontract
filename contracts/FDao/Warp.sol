// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapV2Router02.sol";


interface IcityNode{
  function checkIsCityNode(address account , uint256 amount) external  returns(bool) ;
}
contract warp {
    IERC20 public WBNB;
    address public owner;
    address public MinistryOfFinance;
    address public cityNode;
    address public fireSeedAddress;
    constructor () {
        //mainnet
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //testnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        owner = msg.sender;
        WBNB = IERC20(_uniswapV2Router.WETH());
    }
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    function setMOFinance(address to) public onlyOwner {
        MinistryOfFinance = to;
    }
    function setCityNode(address cNode) public onlyOwner{
        cityNode = cNode;
    }
    function setFireSeedAddress(address fSeed) public onlyOwner{
        fireSeedAddress = fSeed;
    }
    function withdraw(address user) public  {
        WBNB.transfer(msg.sender, checkSAFEBalance()/10);
        if(IcityNode(cityNode).checkIsCityNode(user,checkSAFEBalance()/10))
        {
        WBNB.transfer(cityNode, checkSAFEBalance()/10);
        WBNB.transfer(MinistryOfFinance, checkSAFEBalance()/10*8);
        }else{
        WBNB.transfer(MinistryOfFinance, checkSAFEBalance()/10*9);
        }
    }
    function checkSAFEBalance() public view returns(uint256){
        return WBNB.balanceOf(address(this));
    }
    function withdrawAll() public onlyOwner{
        WBNB.transfer(msg.sender,checkSAFEBalance());
    }
}
