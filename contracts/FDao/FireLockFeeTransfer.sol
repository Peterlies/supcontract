// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
contract FireLockFeeTransfer is Ownable{
    address public setAddr;
function setAddress(address _addr) public onlyOwner{
    setAddr = _addr;
}
function getAddress() external view returns(address) {
    return setAddr;
}
}