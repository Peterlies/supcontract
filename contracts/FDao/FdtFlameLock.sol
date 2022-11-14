// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


contract FdtFlameLock is Ownable{
    address public FdtAddress;
    address public falmeAddress;
    uint256 public TotallockTime = 662256000 ;
    mapping(address => uint256) public FDTtransferTime;
    mapping(address => uint256) public FDTlocked;
    mapping(address => uint256) public FDTUserAmount;

    mapping(address => uint256) public FLAMEtransferTime;
    mapping(address => uint256) public FLAMElocked;
    mapping(address => uint256) public FLAMEUserAmount;
    constructor() {

    }
    function setTokenAddress(address _FdtAddress, address _falmeAddress) public onlyOwner {
        FdtAddress = _FdtAddress;
        falmeAddress = _falmeAddress;
    }
    function withdraw(address tokenAddress ,uint256 amount) public onlyOwner {
        if(tokenAddress == FdtAddress){
            IERC20(tokenAddress).transfer(msg.sender,amount);
        }else if(tokenAddress == falmeAddress){
            IERC20(tokenAddress).transfer(msg.sender,amount);
        }
    }

    function Fdtlocked(uint256 amount) public {
        require(IERC20(FdtAddress).balanceOf(msg.sender) != 0, "You not have balance");
        require(IERC20(FdtAddress).balanceOf(msg.sender) <= amount , "you not have enough balance");
        IERC20(FdtAddress).transfer(address(this), amount);
        FDTtransferTime[msg.sender] = block.timestamp;
        FDTlocked[msg.sender] = TotallockTime;
        FDTUserAmount[msg.sender] = amount;
    }
    function FlameLocked(uint256 amount) public {
        require(IERC20(falmeAddress).balanceOf(msg.sender) != 0,"you have not balance");
        require(IERC20(falmeAddress).balanceOf(msg.sender) <= amount, "you not have enough balance");
        IERC20(falmeAddress).transfer(address(this), amount);
        FLAMEtransferTime[msg.sender] = block.timestamp;
        FLAMElocked[msg.sender] = TotallockTime;
        FLAMEUserAmount[msg.sender] = amount;

    }
    function claim(address tokenAddress , uint256 amount) public {
        require(FDTUserAmount[msg.sender] > amount || FLAMEUserAmount[msg.sender] > amount, "you amount error");
        require(block.timestamp > FLAMElocked[msg.sender] || block.timestamp > FDTlocked[msg.sender],"you lock time not end");
        if(tokenAddress == FdtAddress && FDTUserAmount[msg.sender] * (block.timestamp - FDTtransferTime[msg.sender])/TotallockTime > amount){
        IERC20(tokenAddress).transfer(msg.sender, amount);
        }else if(tokenAddress == falmeAddress &&  FLAMEUserAmount[msg.sender] * (block.timestamp - FLAMEtransferTime[msg.sender])/TotallockTime > amount){
        IERC20(tokenAddress).transfer(msg.sender, amount);
        }
    }
}