// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TeamFundingAllocation is Initializable, UUPSUpgradeable, AccessControlEnumerableUpgradeable {
    
    IERC20 weth;
    address public mainAddr;
    address[] public secondary;
    mapping(address => uint256) public allocationCycle;
    mapping(address => uint256) public maximumAmount;
    mapping(address => uint256) public billingCycle;
    mapping(address => uint) public rate;
    function initialize() public initializer {
        __UUPSUpgradeable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
     function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
    function setMainAddr(address _addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
        mainAddr = _addr;
    }
    function setWeth(IERC20 _addr) public onlyRole(DEFAULT_ADMIN_ROLE){
        weth = _addr;
    }
    function initAssignment(
        address _mainAddr,
        uint rate_,
        address[] memory _secondary,
        uint256[] memory _allocationCycle,
        uint256[] memory _maximumAmount,
        uint256[] memory _billingCycle,
        uint[] memory _rate
        ) public onlyRole(DEFAULT_ADMIN_ROLE){
            mainAddr = _mainAddr;
            rate[_mainAddr] = rate_;
            for(uint i = 0; i < _secondary.length;i++){
                secondary.push(_secondary[i]);
                allocationCycle[_secondary[i]] = _allocationCycle[i];
                maximumAmount[_secondary[i]] = _maximumAmount[i];
                billingCycle[_secondary[i]] = _billingCycle[i];
                rate[_secondary[i]] = _rate[i];
            }
    }
    function allocateFunds() public {
        
    }
    function balance() public view returns(uint256) {
        return weth.balanceOf(address(this));
    }
}