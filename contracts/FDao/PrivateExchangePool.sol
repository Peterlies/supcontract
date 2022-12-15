//	SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IFireSoul {
	function checkFID(address user) external view returns(bool);
}
interface ILockForPrivateExchangePool {

	function withDraw(uint256 _id,address _user, uint256 _amount) external;
}
interface ISbt001{
	function mint(address Account, uint256 Amount) external;
	function burn(address Account, uint256 Amount) external;
}
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
	address public sbt001;	
	// address public fireSoul;
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
		// fireSoul = _fireSoul;
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
    	function setSbt001Address(address _sbt001) public onlyOwner {
		sbt001 = _sbt001;
	}
	function setLockForPrivateExchangePool(address _lock) public onlyOwner {
		lock = _lock;
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
		// require(IFireSoul(fireSoul).checkFID(msg.sender), "you haven't FID,plz do this first");
		require(userTotalBuy[msg.sender] + msg.value <= 5000000000000000000,"fireDao ID only buy 5 ETH");
		feeReceiver.transfer(msg.value);
		
		fdt.transfer(msg.sender, msg.value*getLatesPrice()/10**8 * 1000/salePrice * 3/10);
		fdt.transfer(lock, msg.value*getLatesPrice()/10**8 * 1000/salePrice * 7/10);
		userLock memory info = userLock({amount:msg.value*getLatesPrice()/10**8 * 1000/salePrice *7/10, startTime:block.timestamp, endTime:block.timestamp + lockTime});
		userLocks[msg.sender].push(info);
		userTotalBuy[msg.sender] += msg.value;
		ISbt001(sbt001).mint(msg.sender, msg.value*getLatesPrice()/10**8 * 1000/salePrice * 7/10);

	}

	function withDrawLock(uint256 id_,address user_, uint256 amount_) public {
		ILockForPrivateExchangePool(lock).withDraw(id_, user_, amount_);
		ISbt001(sbt001).burn(msg.sender, amount_);
	}
	function getUserBuyLength(address _user) external view returns(uint256) {
		return userLocks[_user].length;
	}
	function getUserLockEndTime(address _user, uint256 lockId) external view returns(uint256) {
		return userLocks[_user][lockId].endTime;
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
interface IPrivateExchangePool {
	function getUserBuyLength(address _user) external view returns(uint256);
	function getUserLockEndTime(address _user, uint256 lockId) external view returns(uint256);
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
	function withDraw(uint256 _id,address _user, uint256 _amount) external {
		require(msg.sender == exchangePool, "error");
		require(IPrivateExchangePool(exchangePool).getUserBuyLength(_user) >= 0, "you haven't lock amount");
		require(block.timestamp > IPrivateExchangePool(exchangePool).getUserLockEndTime(_user, _id) , "Your lockup has not expired");
		fdt.transfer(msg.sender, _amount);
	}

}
