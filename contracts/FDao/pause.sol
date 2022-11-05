// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


interface IautoReflowLp{
      function setPause() external;
}
interface IFidPromotionCompetition {
    function setContractsStatus() external;
}
interface IFireSeedAndFSoul{
    function setStatus() external;
}
contract pause is Ownable {
    address public autoReflowLpAddress;
    address public FidPromotionCompetitionAddress;
    address public FireSeedAndFSoulAddress;
    uint256 public pauseTime = 259200;
    uint256 public pauseStartTime;
    uint256 public pauseEndTime;
    constructor() {

    }
    function setContractsAddress(address[] memory aim) public onlyOwner {
        autoReflowLpAddress = aim[0];
    FidPromotionCompetitionAddress = aim[1];
    FireSeedAndFSoulAddress = aim[2];
    }
    function setStatus() public onlyOwner {
        require(block.timestamp > pauseEndTime);
        IautoReflowLp(autoReflowLpAddress).setPause();
        IFidPromotionCompetition(FidPromotionCompetitionAddress).setContractsStatus();
        IFireSeedAndFSoul(FireSeedAndFSoulAddress).setStatus();
        pauseStartTime = block.timestamp;
        pauseEndTime = pauseStartTime +  pauseTime;
        
    }
}