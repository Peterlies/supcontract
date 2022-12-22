//	SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./interface/IFireSeed.sol";
import "./interface/IFireSoul.sol";
import "./interface/ISbt001.sol";
import "./interface/IPrivateExchangePool.sol";
import "./interface/ILockForPrivateExchangePool.sol";

contract PrivateExchangePool is Ownable {
	
	struct userLock{
		uint256 amount;
		uint256 startBlock;
		uint256 endBlock;
	}
	uint256 private lockBlock = 2628000;
	ERC20 fdt;
	address payable public feeReceiver;
	address payable public rainbowCityFundation;
	address payable public devAndOperation;
	address public sbt001;	
	address public fireSoul;
	address public fireSeed;
	address public lock;
	uint256 private salePrice = 5;
	bool public FeeStatus;
	mapping(address => userLock[]) public userLocks;
	mapping(address => uint256) public userTotalBuy;
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
	function setSalePrice(uint256 _salePrice) public onlyOwner {
		salePrice = _salePrice;
	}
	function changeFeeReceiver(address payable receiver) external onlyOwner {
      		feeReceiver = receiver;
    	}
	function changeRainbowCityFundation(address payable _rainbowCityFundation) public onlyOwner {
		rainbowCityFundation = _rainbowCityFundation;
	}
	function changeDevAndOperation(address payable _devAndOperation) public onlyOwner {
		devAndOperation = _devAndOperation;
	}

    	function setSbt001Address(address _sbt001) public onlyOwner {
		sbt001 = _sbt001;
	}
	function setLockForPrivateExchangePool(address _lock) public onlyOwner {
		lock = _lock;
	}
	function setFireSeed(address _fireSeed) public onlyOwner {
		fireSeed = _fireSeed;
	}
	function setFireSoul(address _fireSoul) public onlyOwner {
		fireSoul = _fireSoul;
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
		require(msg.value*getLatesPrice()/10**8 * 1000/salePrice < getBalanceOfFDT(), "the contract FDT balance is not enough");
		require(IFireSoul(fireSoul).checkFID(msg.sender), "you haven't FID,plz do this first");
		require(userTotalBuy[msg.sender] + msg.value <= 5000000000000000000,"fireDao ID only buy 5 ETH");
		feeReceiver.transfer(msg.value*3/10);
		rainbowCityFundation.transfer(msg.value*3/10);
		devAndOperation.transfer(msg.value*3/10);
		payable (IFireSeed(fireSeed).upclass(msg.sender)).transfer(msg.value*5/100);
		payable (IFireSeed(fireSeed).upclass(IFireSeed(fireSeed).upclass(msg.sender))).transfer(msg.value*3/100);
		payable (IFireSeed(fireSeed).upclass(IFireSeed(fireSeed).upclass(IFireSeed(fireSeed).upclass(msg.sender)))).transfer(msg.value*2/100);
		fdt.transfer(msg.sender, msg.value*getLatesPrice()/10**8 * 1000/salePrice * 3/10);
		fdt.transfer(lock, msg.value*getLatesPrice()/10**8 * 1000/salePrice * 7/10);
		userLock memory info = userLock({amount:msg.value*getLatesPrice()/10**8 * 1000/salePrice *7/10, startBlock:block.number, endBlock:block.number + lockBlock});
		userLocks[msg.sender].push(info);
		userTotalBuy[msg.sender] += msg.value;
		ISbt001(sbt001).mint(msg.sender, msg.value*getLatesPrice()/10**8 * 1000/salePrice * 7/10);

	}

	function withDrawLock(uint256 id_,address user_, uint256 amount_) public {
		require(amount_ <= this.getUserExtractable(user_,id_), "you must check getUserExtractable()");
		require(userLocks[user_][id_].amount != 0,"no amount to withDraw");
		ILockForPrivateExchangePool(lock).withDraw(user_, amount_);
		ISbt001(sbt001).burn(msg.sender, amount_);
		userLocks[user_][id_].startBlock = block.number;
		userLocks[user_][id_].amount -=  amount_;

	}
	function getUserBuyLength(address _user) external view returns(uint256) {
		return userLocks[_user].length;
	}
	function getUserLockEndBlock(address _user, uint256 lockId) external view returns(uint256) {
		return userLocks[_user][lockId].endBlock;
	}
	function getUserLockStartBlock(address _user, uint256 lockId) external view returns(uint256) {
		return userLocks[_user][lockId].startBlock;
	}
	function getUserExtractable(address _user, uint256 lockId) external view returns(uint256) {
		return userLocks[_user][lockId].amount * (block.number - userLocks[_user][lockId].startBlock)/lockBlock;
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

contract LockForPrivateExchangePool is Ownable {
	ERC20 fdt;
	address public exchangePool;
	constructor (address _exchangePool) {exchangePool = _exchangePool;}
	function setFdt(ERC20 _fdt) public onlyOwner {
		fdt = _fdt;
	}
	function setExchangePool(address _exchangePool) public onlyOwner {
		exchangePool = _exchangePool;
	}
	function withDraw(address _user, uint256 _amount) external {
		require(msg.sender == exchangePool, "error");
		require(IPrivateExchangePool(exchangePool).getUserBuyLength(_user) >= 0, "you haven't lock amount");
		fdt.transfer(msg.sender, _amount);
	}

}
