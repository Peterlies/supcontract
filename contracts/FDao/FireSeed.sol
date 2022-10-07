// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";



contract FireSeed is ERC1155PresetMinterPauser{

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
    mapping(address => accountInfo) public _accountAirdrop;
    address[] public _accountList;



    uint8 tokenId = 1;
    constructor() ERC1155PresetMinterPauser("test"){

    }
    function mintToken(uint256 amount ) public {
        mint(msg.sender,tokenId, amount ,"test");
    }
    function transferToken(
            address from,
            address to
    
        ) public {

        if (recommender[to] == address(0) && !from.isContract() && !to.isContract() && recommender[from] != to && !isRecommender[to]) {
            recommender[to] = from;
            recommenderInfo[from].push(to);
            isRecommender[to] = true;
        }
        accountInfo storage info = _accountAirdrop[to];
        if (!info.isAccount && !to.isContract()) {
            _accountList.push(to);
            info.isAccount = true;
        }


        safeTransferFrom(from, to, tokenId, tokenId ,"test");
    }
}