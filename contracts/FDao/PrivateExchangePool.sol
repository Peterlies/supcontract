//	SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract PrivateExchangePool is Ownable {
	
	
	struct userLock{
		uint256 amount;
		uint256 startTime;
		uint256 endTime;
	}
	uint256 private lockTime = 31536000;	
	address private feeTo;
	address private fdt;
	address public USDT;
		
	mapping(address => uint256) public userLockBalance;
	mapping(address => userLock[]) public userLocks;

	constructor() {
	}
	//onlyOwner
	function setFDTAddress(address _fdt) public onlyOwner {
		fdt = _fdt;
	}
	function setUSDTaddress(address _usdt) public  onlyOwner{
		USDT = _usdt;
	}
	function setFeeRevicer(address _to) public onlyOwner{
		feeTo = _to;
	}
	//main
	function exchangeFdt(uint256 _amount) public{
		IERC20(USDT).transferFrom(msg.sender,feeTo, _amount);
		IERC20(fdt).transfer(msg.sender, _amount*3/10);
		
		userLock memory info = userLock({amount:_amount, startTime:block.timestamp, endTime:block.timestamp});
		userLocks[msg.sender].push(info);

	}


}

