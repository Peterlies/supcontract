// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TreasuryDistributionContractV2.sol";
contract TreasuryDistributionContractV3 is TreasuryDistributionContractV2{
    mapping(uint256 => address) public setNewAddr;
    function newSetAddress(uint256 num, address _addr) public virtual {
        setAddr[num] = _addr;
    }
     function getVersionUp() public pure virtual returns (string memory) {
        return "2.0.1";
    }
}