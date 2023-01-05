// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./lib/SafeMath.sol";
import "./interface/IUniswapV2Router02.sol";
import "./interface/IFireSeed.sol";
import "./interface/IFireSoul.sol";
import "./interface/IUniswapV2Pair.sol";
import "./interface/IUniswapV2Factory.sol";
import "./interface/GetWarp.sol";
import "./interface/IMinistryOfFinance.sol";

contract FireDaoToken is ERC20 ,Ownable{
    using SafeMath for uint256;
    address public  uniswapV2Pair;
    address _tokenOwner;
    address public fireSoul;
    address public  ministryOfFinance;
    IUniswapV2Router02 public uniswapV2Router;
    IFireSeed public fireSeed;
    IERC20 public WBNB;
    IERC20 public pair;
    GetWarp public warp;
    bool private swapping;
    uint256 public swapTokensAtAmount;
    uint256 _destroyMaxAmount;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public allowAddLPList;
    mapping(address => uint256) private LPAmount;
    bool public swapAndLiquifyEnabled;
    bool public openTrade;
    uint256 public startTime;
    uint256[3] public distributeRates = [5e3, 2e3, 5e2];
    uint256 private currentTime;
    uint8  _tax ;
    uint256  _currentSupply;
    address public _bnbPool;
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    constructor(address tokenOwner) ERC20("Fire Dao Token", "FDT") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        _approve(address(this), address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), 10**34);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _bnbPool = _uniswapV2Pair;
        _tokenOwner = tokenOwner;
        excludeFromFees(tokenOwner, true);
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        whiteListOfAddLP(tokenOwner, true);
        whiteListOfAddLP(owner(), true);
        whiteListOfAddLP(address(this), true);
        setSwapAndLiquifyEnabled(true);
        WBNB = IERC20(_uniswapV2Router.WETH());
        pair = IERC20(_uniswapV2Pair);
        uint256 total = 10**28;
        swapTokensAtAmount = 5 * 10**19;
        _mint(tokenOwner, total);
        _currentSupply = total;
        currentTime = block.timestamp;
        _tax = 5;
    }

    receive() external payable {}

    function currentSupply() public view virtual returns (uint256) {
        return _currentSupply;
    }
    //onlyOwner
    function whiteListOfAddLP(address usr, bool enable) public onlyOwner {
        allowAddLPList[usr] = enable;
    }
    function setTax(uint8 tax) public onlyOwner {
        require(tax <=5 , 'tax too big');
        _tax = tax;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function whiteList(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

  

     function setSwapTokensAtAmount(uint256 _swapTokensAtAmount) public onlyOwner {
        swapTokensAtAmount = _swapTokensAtAmount;
    }
	
	function changeSwapWarp(GetWarp _warp) public onlyOwner {
        warp = _warp;
    }

    function changesFireSeed(IFireSeed _fireSeed) public onlyOwner{
        fireSeed = _fireSeed;
    }

    function warpWithdraw(address user) public onlyOwner {
        warp.withdraw(user);
    }
    function setOpenTrade(bool _enabled) public onlyOwner{
        openTrade = _enabled;
    }
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }
    function setfireSoul(address _fireSoul) public onlyOwner {
        fireSoul = _fireSoul;
    }

    function setMinistryOfFinance(address _ministryOfFinance ) public onlyOwner{
        ministryOfFinance = _ministryOfFinance;
    }
    //main
    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }
    
    function burn(uint256 burnAmount) external {
        _burn(msg.sender, burnAmount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount>0);
        
		if(from == address(this) || to == address(this)){
            super._transfer(from, to, amount);
            return;
        }

        if(from == uniswapV2Pair || to == uniswapV2Pair){
          require(openTrade || allowAddLPList[from], "no trade");
        }

        if(startTime == 0 && balanceOf(uniswapV2Pair) == 0 && to == uniswapV2Pair){
            startTime = block.timestamp;
        }

        bool takeFee;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }else if(to == uniswapV2Pair){
            takeFee = false;
        }else{
            takeFee = true;
        }
        if (takeFee) {
            super._transfer(from, address(this), amount.div(100).mul(_tax));//fee 5%
            amount = amount.div(100).mul(100-_tax);//95%
        }
        super._transfer(from, to, amount);
    }
     

    function swapTokensForOther(uint256 tokenAmount) private {
		address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(warp),
            block.timestamp
        );
        warp.withdraw(msg.sender);
    }

    function _splitOtherTokenSecond(uint256 thisAmount) private {
	    address[] memory user = new address[](3);
        user[0] = fireSeed.upclass(msg.sender);
        user[1] = fireSeed.upclass(user[0]);
        user[2] = fireSeed.upclass(user[1]);
        if(user[1] == address(0) || user[2] == address(0)){
            revert();
        }else if(IFireSoul(fireSoul).checkFID(msg.sender) && 
                    IFireSoul(fireSoul).checkFID(user[0]) &&
                    IFireSoul(fireSoul).checkFID(user[1]) &&
                    IFireSoul(fireSoul).checkFID(user[2])  )
                     {
                    for(uint256 i = 0; i < distributeRates.length; i++){
                        WBNB.transfer(user[i], thisAmount.mul(distributeRates[i]).div(100));
                        }
                     }else{
                        uint total = 0;
                    for(uint256 i = 0; i < distributeRates.length; i++){
                         WBNB.transfer(ministryOfFinance,thisAmount.mul(distributeRates[i]).div(100));
                         total += thisAmount.mul(distributeRates[i]).div(100);
                    }
                    IMinistryOfFinance(ministryOfFinance).setSourceOfIncome(1, total);
        }
    }

}