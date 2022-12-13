//	SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


// FireDaoToken 0x6a7858fE9d76eeE661642561Ba06db24f293369C
//	PRIVATEEXCHANGEPOOL 0x1551Cf5A77aDeeB45EB757E26FeA391eb7dd1547
contract PrivateExchangePool is Ownable {
	
	
	struct userLock{
		uint256 amount;
		uint256 startTime;
		uint256 endTime;
	}
	uint256 private lockTime = 31536000;	
	ERC20 fdt;
    address payable public feeReceiver;
    // uint public fee;
    bool public FeeStatus;
	mapping(address => uint256) public userLockBalance;
	mapping(address => userLock[]) public userLocks;
	AggregatorV3Interface internal priceFeed;
	/**
		* NetWork: Goerli
		* Aggregator: ETH/USD
		* Address:0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
		*/

	constructor() {
		priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
	}
	//onlyOwner
	function setFeeStatus() public onlyOwner{
      FeeStatus = !FeeStatus;
   }
	function setFDTAddress(ERC20 _fdt) public onlyOwner {
		fdt = _fdt;
	}

	function changeFeeReceiver(address payable receiver) external onlyOwner {
      feeReceiver = receiver;
    }
	//main
	function exchangeFdt() public payable {
		require(msg.value == 100000000000000000 || 
				msg.value == 200000000000000000 ||
				msg.value == 300000000000000000 ||
				msg.value == 400000000000000000 ||
				msg.value == 500000000000000000 ||
				msg.value == 600000000000000000 ||
				msg.value == 700000000000000000 ||
				msg.value == 800000000000000000 ||
				msg.value == 900000000000000000 ||
				msg.value == 1000000000000000000 ,
				"input is error"
				);
		feeReceiver.transfer(msg.value);
		
		fdt.transfer(msg.sender, msg.value*getLatesPrice()/10**8 * 1000/5 * 3/10);
		userLock memory info = userLock({amount:msg.value*getLatesPrice()/10**8 * 1000/5 *7/10, startTime:block.timestamp, endTime:block.timestamp + lockTime});
		userLocks[msg.sender].push(info);

	}
	function getUserbuylength() public view returns(uint256) {
		return userLocks[msg.sender].length;
	}
   	

	function getLatesPrice() public view returns (uint256) {
		(
			,
			int price,
			,
			,
			
		) = priceFeed.latestRoundData();

		return uint256(price);
	}

	function getBalanceOfFDT() public view returns(uint256) {
		return fdt.balanceOf(address(this));
	}
    receive() external payable {}
}

