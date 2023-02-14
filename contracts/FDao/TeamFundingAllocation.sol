// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TeamFundingAllocation is Initializable, UUPSUpgradeable, AccessControlEnumerableUpgradeable {
    IERC20 weth;
    bool public status;
    address public mainAddr;
    uint256 public billingCycle;
    address[] public secondary;
    mapping(address => bool) public reachQuota;
    mapping(address => uint256) public totalAmount;
    mapping(address => uint256) public allocationCycle;
    mapping(address => uint256) public maximumAmount;
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
        uint256 _billingCycle,
        address[] memory _secondary,
        uint256[] memory _allocationCycle,
        uint256[] memory _maximumAmount,
        uint[] memory _rate
        ) public onlyRole(DEFAULT_ADMIN_ROLE){
            mainAddr = _mainAddr;
            rate[_mainAddr] = rate_;
            billingCycle = _billingCycle;
            for(uint i = 0; i < _secondary.length;i++){
                secondary.push(_secondary[i]);
                allocationCycle[_secondary[i]] = _allocationCycle[i];
                maximumAmount[_secondary[i]] = _maximumAmount[i];
                rate[_secondary[i]] = _rate[i];
            }
        status = true;
    }
    function allocateFunds() public {
        require(getTotalRate() == 100, "Please adjust the allocation ratio");
        require(status,"Please initialize the contract");
        require(billingCycle > block.timestamp,"Unable to allocate beyond the billing cycle");
        uint256 amount = balance();
        for(uint i = 0; i<secondary.length;i++){
            if(
            totalAmount[secondary[i]] > maximumAmount[secondary[i]] &&
            !reachQuota[secondary[i]] &&
            allocationCycle[secondary[i]] > block.timestamp
              ){
            reachQuota[secondary[i]] = true;
            }else{
            weth.transfer(secondary[i],amount*rate[secondary[i]]/100);
            totalAmount[secondary[i]] += amount*rate[secondary[i]]/100;
            }
        }
    }
    function getSecondaryLength() public view returns(uint256){
        return secondary.length;
    }
    function getTotalRate() public view returns(uint){
        uint totalRate;
        for(uint i = 0; i<secondary.length;i++){
           totalRate += rate[secondary[i]];
        }
        return rate[mainAddr] + totalRate;
    }
    function balance() public view returns(uint256) {
        return weth.balanceOf(address(this));
    }
}