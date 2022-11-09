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
interface ICityNodePromotionCompetition{
       function setStatus() external ;
}
interface IEcologicalIncomeDividend{
    function setContractStatus() external;
}
interface IFlameFdtExchange {
    function setStatus() external ;
}
interface IAirdropFlame{
    function setStatus() external ;
}
contract Pause is Ownable {
    address public autoReflowLpAddress;
    address public FidPromotionCompetitionAddress;
    address public FireSeedAndFSoulAddress;
    address public CityNodePromotionCompetition;
    address public EcologicalIncomeDividend;
    address public FlameFdtExchangeAdress;
    address public AirdropFlameAddress;
    uint256 public pauseTime = 259200;
    uint256 public pauseStartTime;
    uint256 public pauseEndTime;
    constructor() {

    }
    function setContractsAddress(address[] memory aim) public onlyOwner {
        autoReflowLpAddress = aim[0];
    FidPromotionCompetitionAddress = aim[1];
    FireSeedAndFSoulAddress = aim[2];
    CityNodePromotionCompetition = aim[3];
    EcologicalIncomeDividend = aim[4];
    FlameFdtExchangeAdress = aim[5];
    AirdropFlameAddress = aim[6];
    }
    function setStatus() public onlyOwner {
        require(block.timestamp > pauseEndTime);
        IautoReflowLp(autoReflowLpAddress).setPause();
        IFidPromotionCompetition(FidPromotionCompetitionAddress).setContractsStatus();
        IFireSeedAndFSoul(FireSeedAndFSoulAddress).setStatus();
        ICityNodePromotionCompetition(CityNodePromotionCompetition).setStatus();
        IEcologicalIncomeDividend(EcologicalIncomeDividend).setContractStatus();
        IFlameFdtExchange(FlameFdtExchangeAdress).setStatus();
        IAirdropFlame(AirdropFlameAddress).setStatus();
        pauseStartTime = block.timestamp;
        pauseEndTime = pauseStartTime +  pauseTime;
        
    }
}