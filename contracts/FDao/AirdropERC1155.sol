// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract AirdropERC1155 {
    IERC1155 public token;
    address public passport;
    constructor(IERC1155 _token, address _passport){
        token = _token;
        passport = _passport;

    }
    function Claim() public {
        require(IERC721(passport).balanceOf(msg.sender) !=0 ,"")
    }
    function getUser() public view returns(uint) {

    }
}