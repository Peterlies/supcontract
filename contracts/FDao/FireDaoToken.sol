// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./lib/SafeMath.sol";
import "./interface/IUniswapV2Router02.sol";
import "./interface/IFireSeed.sol";
import "./interface/IUniswapV2Pair.sol";
import "./interface/IUniswapV2Factory.sol";
import "./interface/GetWarp.sol";

contract FireDaoToken is ERC20 ,Ownable{
    using SafeMath for uint256;
	mapping(address => address) inviter;
    mapping(address => address) inviterPrepare;
    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    address _tokenOwner;
    address public FID;
    address public  MinistryOfFinance;

    IFireSeed public fireSeed;

    IERC20 public USDT;
    IERC20 public WBNB;
    IERC20 public pair;
    GetWarp public warp;
    bool private swapping;
    uint256 public swapTokensAtAmount;
    uint256 _destroyMaxAmount;
	// address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    // address private _MarketAddress = address(0xC60045314Fd865DA83e822bba4856b0bf0888888);
    mapping(address => bool) private _isExcludedFromFees;
    bool public swapAndLiquifyEnabled = true;
    uint256 public startTime;

    uint256[3] public distributeRates = [5e3, 2e3, 5e2];


    uint256 private intervalTime = 0;
    uint256 private currentTime;
    uint8  _tax = 5 ;
    uint256 public _currentSupply;


    mapping(address => bool) public isRecommender;
    mapping(address => address) public recommender;
    mapping(address => address[]) public recommenderInfo;

    struct accountInfo {
        bool isAccount;
        uint256 settleTime;
        uint256 incomeTime;
        uint256 incomeAmount;
        uint256 cacheAmount;
    }

    address public _bnbPool;
    address[] buyUser;
    mapping(address => bool) public havePush;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SwapAndSendTo(
        address target,
        uint256 amount,
        string to
    );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived
    );

    constructor(address tokenOwner) ERC20("Fire Dao Token", "FDT") {
        
        //mainnet    
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //testnet
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
        // USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);//mainnet
        WBNB = IERC20(_uniswapV2Router.WETH());
        pair = IERC20(_uniswapV2Pair);
        uint256 total = 10**28;
        swapTokensAtAmount = 5 * 10**19;
        _mint(tokenOwner, total);
        _currentSupply = total;
        currentTime = block.timestamp;
    }

    receive() external payable {}

    function currentSupply() public view virtual returns (uint256) {
        return _currentSupply;
    }
    
    function updateUniswapV2Router(address newAddress) public onlyOwner {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
	
     //排除出分红，enable为true是永久禁止分红，false是不禁止
    function excludeFromShare(address account, bool enable) public onlyOwner{

        for(uint i = 0; i < buyUser.length; i++){
            if(buyUser[i] == account){
                buyUser[i] = buyUser[buyUser.length-1];
                buyUser.pop();
            }
        }

        havePush[account] = enable;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setIntervalTime(uint256 _intervalTime) public onlyOwner {
        intervalTime = _intervalTime;
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

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }
    function setFIDAddress(address _FID) public onlyOwner {
        FID = _FID;
    }

    function setMinistryOfFinance(address _MinistryOfFinance ) public onlyOwner{
        MinistryOfFinance = _MinistryOfFinance;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }
    
    function burn(uint256 burnAmount) external {
        _burn(msg.sender, burnAmount);
    }

    function setTax(uint8 tax) public onlyOwner {
        require(tax <=5 , 'tax too big');
        _tax = tax;
    }

    // function setPayAble() public {
    //     // payable(msg.sender);
    // }

    // function recommenderNumber(address account) external view returns (uint256) {
    //     return recommenderInfo[account].length;
    // }

    // function _beforeTransfer(
    //         address from,
    //         address to
    // ) internal {
    //     if (recommender[to] == address(0) && !from.isContract() && !to.isContract() && recommender[from] != to && !isRecommender[to]) {
    //         recommender[to] = from;
    //         recommenderInfo[from].push(to);
    //         isRecommender[to] = true;
    //     }
    //     accountInfo storage info = _accountAirdrop[to];
    //     if (!info.isAccount && !to.isContract()) {
    //         _accountList.push(to);
    //         info.isAccount = true;
    //     }
    // }



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
        
        if(balanceOf(address(this)) > swapTokensAtAmount && block.timestamp >= (currentTime + intervalTime)){
            if (
                !swapping &&
                _tokenOwner != from &&
                _tokenOwner != to &&
                from != uniswapV2Pair &&
                swapAndLiquifyEnabled
            ) {
                swapping = true;
                currentTime = block.timestamp;//更新时间
                uint256 tokenAmount = balanceOf(address(this));
                swapAndLiquifyV3(tokenAmount);
                swapping = false;
            }
        }

        if(from == uniswapV2Pair || to == uniswapV2Pair){
            _splitOtherToken();

        }

        if(startTime == 0 && balanceOf(uniswapV2Pair) == 0 && to == uniswapV2Pair){
            startTime = block.timestamp;
        }

        bool takeFee = !swapping;
        
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }else{
			if(from == uniswapV2Pair){ //buy
                if(startTime.add(60) > block.timestamp){amount = amount.div(5);}
            }else if(to == uniswapV2Pair){//sell
            
            }else{
                takeFee = true;
            }
        }
        if (takeFee) {

            // if(to == uniswapV2Pair){//卖出
            
                // if(_currentSupply > 100* 10**4 * 10**decimals()){
                //     super._transfer(from, _destroyAddress, amount.div(100).mul(1));//1%销毁
                //     _currentSupply = _currentSupply.sub(amount.div(100).mul(1));
                // }else{
                //     super._transfer(from, uniswapV2Pair, amount.div(100).mul(1));//回流1%
                // }

                super._transfer(from, address(this), amount.div(100).mul(_tax));//fee 5%

                amount = amount.div(100).mul(100-_tax);//95%

            // }else if(from == uniswapV2Pair){// 买入
            //     super._transfer(from, uniswapV2Pair, amount.div(100).mul(1));//回流1%
            //     super._transfer(from, address(this), amount.div(100).mul(1));//分红1%
            //     amount = amount.div(100).mul(98);//98%
            // }else{}
        }
        super._transfer(from, to, amount);
        
        if(!havePush[from] && to == uniswapV2Pair){
            havePush[from] = true;
            buyUser.push(from);
        }
    }

    function swapAndLiquifyV3(uint256 contractTokenBalance) public {
        swapTokensForOther(contractTokenBalance);
    }
    
    function swapTokensForOther(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
		address[] memory path = new address[](2);
        path[0] = address(this);
        // path[1] = address(0x55d398326f99059fF775485246999027B3197955);//mainnet
        // path[1] = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);//testnet
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


    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    uint256 public ldxindex;

    function _splitOtherTokenSecond(uint256 thisAmount) private {
        // uint256 buySize = buyUser.length;
        // if(buySize>0){
        //     address user;
        //     uint256 totalAmount = pair.totalSupply();
        //     uint256 rate;
        //     if(buySize >20){
        //         for(uint256 i=0;i<20;i++){
        //             ldxindex = ldxindex.add(1);
        //             if(ldxindex >= buySize){ldxindex = 0;}
        //             user = buyUser[ldxindex];
        //             if(balanceOf(user) >= 0){
        //                 rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
        //                 uint256 amountUsdt = thisAmount.mul(rate).div(1000000);
        //                 if(amountUsdt>10**13){
        //                     USDT.transfer(user,amountUsdt);
        //                 }
        //             }
        //         }
        //     }else{
        //         for(uint256 i=0;i<buySize;i++){
        //             user = buyUser[i];
        //             if(balanceOf(user) >= 0){
        //                 rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
        //                 uint256 amountUsdt = thisAmount.mul(rate).div(1000000);
        //                 if(amountUsdt>10**13){
        //                     USDT.transfer(user,amountUsdt);
        //                 }
        //             }
        //         }
        //     }
        // }

        // for(uint256 i = 0; i <  distributeRates.length;i++ ){

        // }
	    address[] memory user = new address[](3);

        user[0] = fireSeed.upclass(msg.sender);
        user[1] = fireSeed.upclass(user[0]);
        user[2] = fireSeed.upclass(user[1]);
        if(user[1] == address(0) || user[2] == address(0)){
            revert();
        }else if(IERC721(FID).balanceOf(msg.sender) != 0 && 
                    IERC721(FID).balanceOf(user[0]) != 0 &&
                    IERC721(FID).balanceOf(user[1]) != 0 &&
                    IERC721(FID).balanceOf(user[2]) != 0 )
                     {
                    for(uint256 i = 0; i < distributeRates.length; i++){
                        WBNB.transfer(user[i], thisAmount.mul(distributeRates[i]).div(100));
                        }
                     }else{
                    for(uint256 i = 0; i < distributeRates.length; i++){
                         WBNB.transfer(MinistryOfFinance,thisAmount.mul(distributeRates[i]).div(100));
                    }
                 }
    
    }

    function _splitOtherToken() public {
        uint256 thisAmount = WBNB.balanceOf(address(this));
        if(thisAmount >= 10**14){
            _splitOtherTokenSecond(thisAmount);
        }
    }
}