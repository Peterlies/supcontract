pragma solidity ^0.8.0;

interface a{
   function sortExternal(uint[] memory data) external pure returns (uint[] memory) ;
}

contract b {
    constructor(){

    }
    address public sort;
    function setaAddress(address _sort)public {
        sort = _sort;
    }
    function useSort(uint[] memory asd) public view returns(uint[] memory){
       return a(sort).sortExternal(asd);
    }
}