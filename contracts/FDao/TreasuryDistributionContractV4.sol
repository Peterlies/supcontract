// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TreasuryDistributionContractV3.sol";
contract TreasuryDistributionContractV4 is TreasuryDistributionContractV3{
    mapping(uint256 => address) public asetNewAddra;
    function newSetAddressof(uint256 num, address _addr) public virtual {
        asetNewAddra[num] = _addr;
    }
     function getVersionUpU() public pure virtual returns (string memory) {
        return "2.0.2";
    }
}