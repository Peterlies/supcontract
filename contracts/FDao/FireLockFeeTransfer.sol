// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
contract FireLockFeeTransfer is Ownable{
    uint public fee;
    address public setAddr;

function setFee(uint _fee) public onlyOwner{
    fee = _fee;
}
function getFee() external view returns(uint) {
    return fee;
}
function setAddress(address _addr) public onlyOwner{
    setAddr = _addr;
}
function getAddress() external view returns(address) {
    return setAddr;
}
}