pragma solidity ^0.8.0;
contract Storage {
 address payable private owner;
 uint256 number;
 constructor(address payable _owner) {
  owner = _owner;
 }
 function store(uint256 num) public {
  number = num;
 }
 function retrieve() public view returns (uint256){
  return number;
 }
 
 function close() public { 
  selfdestruct(owner); 
 }
}