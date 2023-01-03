// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract graphTest{
    event testGraph(address from, uint256 num , address to);

    function setTestGraph(address _from, uint256 _num ,address _to) public {
        emit testGraph(_from,_num, _to);
    }
}
contract graphTest1{
    event testGraph1(address from, uint256 num , address to);

    function setTestGraph1(address _from, uint256 _num ,address _to) public {
        emit testGraph1(_from,_num, _to);
    }
}
