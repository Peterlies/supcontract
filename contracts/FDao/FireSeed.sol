// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";



contract FireSeed is ERC1155PresetMinterPauser {

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
    uint256 public currentMint;

    
    constructor() ERC1155PresetMinterPauser("test"){

    }

    function recommenderNumber(address account) external view returns (uint256) {
        return recommenderInfo[account].length;
    }


    function mintToken(uint256 amount ) public {
        
        mint(msg.sender,tokenId, amount ,"test");

        currentMint +=amount;

    }
    function transferToken(
            address from,
            address to
    
        ) public {
            require(from != address(0));
            require(to != address(0));

        if (recommender[to] == address(0) &&  recommender[from] != to && !isRecommender[to]) {
            recommender[to] = from;
            recommenderInfo[from].push(to);
            isRecommender[to] = true;
        }
        accountInfo storage info = _accountAirdrop[to];
        if (!info.isAccount) {
            _accountList.push(to);
            info.isAccount = true;
        }


        safeTransferFrom(from, to, tokenId, tokenId ,"test");
    }

    
}