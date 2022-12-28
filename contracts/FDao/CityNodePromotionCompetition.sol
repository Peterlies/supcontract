

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapV2Router02.sol";
import "./lib/Address.sol";

interface PoolDistributeAward {
    function distributeAward() external;
}

contract CityNodePromotionCompetition is Ownable {
    IUniswapV2Router02 public uniswapV2Router;
    address public aimToken;
    uint256  public aimAmount; 
    bool public Status;
    address public pauseControlAddress;

    address public _weekPool;
    address public _moonPool;
    address public _yearPool;

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;
    }  
    function setPauseControlAddress(address _pauseControlAddress) public onlyOwner{
        pauseControlAddress = _pauseControlAddress;
    }

    function setStatus() external {
    require(msg.sender == pauseControlAddress,"address is error");
        Status = !Status;
    }
    function setPoolAddress(address _week, address _moon, address _year) public onlyOwner{
        _weekPool = _week;
        _moonPool = _moon;
        _yearPool = _year;
    }
    function TotalDistributeAward_week() external {
        PoolDistributeAward(_weekPool).distributeAward();


    }
}

contract weekPool{
    IUniswapV2Router02 public uniswapV2Router;
        constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;
    }

    function distributeAward(address citynodeUser) external{
    IERC20(uniswapV2Router.WETH()).transfer(msg.sender, 10**17);
    IERC20(uniswapV2Router.WETH()).transfer(citynodeUser,10**17);
    }
    



}
contract moonPool{
       IUniswapV2Router02 public uniswapV2Router;
        constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;
    }
    function distributeAward() external{
    IERC20(uniswapV2Router.WETH()).transfer(msg.sender, 10**17);
    }


}
contract yearPool{
       IUniswapV2Router02 public uniswapV2Router;
        constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;
    }
    function distributeAward() external{
    IERC20(uniswapV2Router.WETH()).transfer(msg.sender, 10**17);
    }

}