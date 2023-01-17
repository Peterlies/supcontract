// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract FireLockFeeTransfer is Initializable, UUPSUpgradeable, AccessControlEnumerableUpgradeable{
    IERC20 public weth;
    function initialize() public initializer {
        __UUPSUpgradeable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        weth = IERC20(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);
    }
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
    function balanceOf() public view returns(uint256) {
        return IERC20(weth).balanceOf(address(this));
    }
    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        weth.transfer(msg.sender, balanceOf());
    }
}