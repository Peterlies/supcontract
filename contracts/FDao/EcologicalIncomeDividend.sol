// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapV2Router02.sol";

contract EcologicalIncomeDividend is Ownable {
    bool public status;
    address public CityNodeAddress;
    address public pauseControlAddress;
    address public FDSBT001Address;
    uint256 public intervalTime;

    IUniswapV2Router02 public uniswapV2Router;

    constructor(address roter){
      IUniswapV2Router02  _uniswapV2Router = IUniswapV2Router02(roter);
        uniswapV2Router = _uniswapV2Router;
    }
    function setcitynodeAddress(address _CityNodeAddress) public onlyOwner{
        CityNodeAddress =_CityNodeAddress;
    }
    function setFDSBT001Address(address _FDSBT001Address) public onlyOwner{
        FDSBT001Address = _FDSBT001Address;
    }
    function setPauseControlAddress(address _pauseControlAddress) public onlyOwner{
        pauseControlAddress = _pauseControlAddress;
    }
    function setContractStatus() external {
        require(msg.sender == pauseControlAddress);
        status = !status;
    }
    function Dividend(address user) external {
        require(msg.sender == CityNodeAddress,"address is error");
        require(IERC20(FDSBT001Address).balanceOf(msg.sender) > 10000 *10 **18 , "you balance not enough");
        require(block.timestamp - intervalTime > 86400, "interval 24 hours");
        intervalTime = block.timestamp;
        IERC20(uniswapV2Router.WETH()).transfer(user, IERC20(FDSBT001Address).balanceOf(msg.sender)/IERC20(FDSBT001Address).totalSupply());
        
    }

}