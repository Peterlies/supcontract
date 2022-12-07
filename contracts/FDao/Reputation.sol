// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "hardhat/console.sol";

contract Reputation is
    Initializable,
    AccessControlEnumerableUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");

    mapping(address => uint256) public SBT001;
    mapping(address => uint256) public SBT002;
    mapping(address => uint256) public SBT003;
    mapping(address => uint256) public SBT004;
    mapping(address => uint256) public SBT005;
    mapping(address => uint256) public SBT006;
    mapping(address => uint256) public SBT007;

  
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setMinter(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, account);
    }

    function setPublisher(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(PUBLISHER_ROLE, account);
    }
    function version() public pure returns (string memory) {
        return "3";
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}

    function setSBT001Address(address _sbt001, uint256 _coefficient) public onlyRole(DEFAULT_ADMIN_ROLE){
        SBT001[_sbt001] = _coefficient;
    }
     function setSBT002Address(address _sbt002, uint256 _coefficient) public onlyRole(DEFAULT_ADMIN_ROLE){
        SBT002[_sbt002] = _coefficient;
    }

}