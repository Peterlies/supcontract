// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";



contract FireSeed is ERC1155PresetMinterPauser{
    uint8 tokenId = 1;
    constructor() ERC1155PresetMinterPauser("test"){

    }
    function mintToken(uint256 amount ) public {
        mint(msg.sender,tokenId, amount ,"test");
    }
}