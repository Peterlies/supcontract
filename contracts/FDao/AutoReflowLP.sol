// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


contract autoReflowLP is Ownable {
    IUniswapV2Router02 public uniswapV2Router;
    address public aimToken;
    uint256  public aimAmount; 
    bool public pause;
    address public pauseControlAddress;

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;
    } 
    function setpauseControlAddress(address _pauseControlAddress) public onlyOwner{
        pauseControlAddress = _pauseControlAddress;
    }

    function setPause() external  {
        require(msg.sender == pauseControlAddress, "address is error");
        pause = !pause;
    }
    function setTokenAddress(address token) public onlyOwner{
    aimToken = token ;
    }
    function addlP(address user) external {
        require(!pause, "the contract is pause");
        uniswapV2Router.addLiquidity(aimToken,uniswapV2Router.WETH(),aimAmount, 10**18,0, 0,address(this),block.timestamp);
        IERC20(uniswapV2Router.WETH()).transfer(user, 10**17);
    }
}