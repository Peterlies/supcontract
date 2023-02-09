// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./AirdropERC1155.sol";

contract AirdropFactory is Ownable {
    IERC1155 token;
    address passport;
    address[] public airdropList;
    constructor(IERC1155 _token ,address _passport){
        token = _token;
        passport = _passport;
    }

    function createAirdrop() public {
        address airdrop = address(new AirdropERC1155(token, passport, owner()));
        airdropList.push(airdrop);
    }
    function resetPassprot(address _passport) public onlyOwner{
        passport = _passport;
    }
    function resetToken(IERC1155 _token) public onlyOwner{
        token = _token;
    }
}