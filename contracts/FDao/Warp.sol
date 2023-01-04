// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapV2Router02.sol";
import "./interface/IMinistryOfFinance.sol";


interface IcityNode{
  function checkIsCityNode(address account , uint256 amount) external  returns(bool) ;
}
contract warp {
    IERC20 public WBNB;
    address public owner;
    address public ministryOfFinance;
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
    //onlyOwner
    function setMinistryOFinance(address _ministryOfFinance) public onlyOwner {
        ministryOfFinance = _ministryOfFinance;
    }
    function setCityNode(address cNode) public onlyOwner{
        cityNode = cNode;
    }
    function setFireSeedAddress(address fSeed) public onlyOwner{
        fireSeedAddress = fSeed;
    }
    //main
    function withdraw(address user) public  {
        WBNB.transfer(msg.sender, balance()/10);
        if(IcityNode(cityNode).checkIsCityNode(user,balance()/10)){
        WBNB.transfer(cityNode, balance()/10);
        WBNB.transfer(ministryOfFinance, balance()/10*8);
        IMinistryOfFinance(ministryOfFinance).setSourceOfIncome(1, balance()/10*8);
        }else{
        WBNB.transfer(ministryOfFinance, balance()/10*9);
        IMinistryOfFinance(ministryOfFinance).setSourceOfIncome(1, balance()/10*9);
        }
    }
    function balance() public view returns(uint256){
        return WBNB.balanceOf(address(this));
    }
    function withdrawAll() public onlyOwner{
        WBNB.transfer(msg.sender,balance());
    }
}
