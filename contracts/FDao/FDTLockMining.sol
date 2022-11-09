// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract FDTLockMining is Ownable {
    address public FDTAddress;
    address public flame;
    mapping(address => mapping(uint256 => uint256)) userStakeInfo;
    // mapping
    mapping(address => StakeInfo) public StakeInfos;
    uint256 public BounsTime;
    uint256 public FlameAmount;
    struct StakeInfo {
        address user;
        uint256 startStakeTime;
        uint256 endStakeTime;
    }
    constructor () {

    }

    function setBonusTime(uint256 _BounsTime) public onlyOwner {
        BounsTime = _BounsTime;
        FlameAmount = IERC20(flame).balanceOf(address(this));
    }
    function withdraw(uint256 amount) public onlyOwner {
        IERC20(flame).transfer(msg.sender,amount);
    }

    function setFDTAddress(address _FDTAddress) public onlyOwner {
        FDTAddress = _FDTAddress;
    }

    function stakeMining(uint256 amount, uint256 inputEndTime ) public {
        require(inputEndTime == 0 || inputEndTime == 1 || inputEndTime == 3 || inputEndTime == 6 || inputEndTime == 12 || inputEndTime == 24 || inputEndTime == 36 , "input type error");

        IERC20(FDTAddress).transfer(address(this), amount);
        userStakeInfo[msg.sender][block.timestamp] = amount;
        StakeInfo memory info = StakeInfo({
            user:msg.sender,
            startStakeTime:block.timestamp,
            endStakeTime:block.timestamp + inputEndTime*2592000
        });
        
        StakeInfos[msg.sender] = info;

    }

    function ReceiveAward() public {
        // IERC20(flame).transfer(user,(FlameAmount/BounsTime))
    }
}
