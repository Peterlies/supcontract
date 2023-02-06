// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interface/IERC20ForLock.sol";
import "./lib/TransferHelper.sol";
import "./interface/IWETH.sol";
contract FireLockMain {
    struct LockDetail{
        string LockTitle;
        bool isNotTerminate;
        uint256 ddl;
        uint256 startTime;
        uint256 amount;
        uint256 unlockCycle;
        uint256 unlockRound;
        address token;
        uint256 cliffPeriod;
    }
    struct groupLockDetail{
        string LockTitle;
        uint256 ddl;
        uint256 startTime;
        address admin;
        uint256 amount;
        uint256 unlockCycle;
        uint256 unlockRound;
        uint256[] rate;
        address token;
        address[] member;
        bool isNotchange;
        bool isNotTerminate;

    }
    address public treasuryDistributionContract;
    uint256 public fee;
    bool public feeON;
    address public owner;
    address public feeReceiver;
    address public weth;
   uint256 public oneDayBlock = 7200;
    address[] public ListTokenAddress;
    mapping(address => address[]) public tokenAddress;
    mapping(uint256 => address[]) public groupMember;
    mapping(address => address) public adminAndOwner;
    mapping(address => LockDetail[]) public ownerLockDetail;
    mapping(address => groupLockDetail[]) public adminGropLockDetail;
    LockDetail[] public ListOwnerLockDetail;
    groupLockDetail[] public ListGropLockDetail;
    modifier onlyOwner{
        require(msg.sender == owner ,"you are not the lock owner");
        _;
    }
    constructor(address _weth ,address _feeReceiver) {
    owner = msg.sender;
    weth = _weth;
    feeReceiver = _feeReceiver;
    fee = 8000000000000000;
    }

     function setFee(uint fees) public  onlyOwner{
      require(fees <= 100000000000000000,'The maximum fee is 0.1ETH');
      fee = fees;
   }
    function setFeeOn() public onlyOwner{
        feeON = !feeON;
    }

    function lock(address _token,address _to,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile , bool _Terminate) public  payable{
        require(block.number + _unlockCycle * _unlockRound * oneDayBlock > block.number,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
             if(feeON){
              if(msg.value == 0) {
              TransferHelper.safeTransferFrom(weth,msg.sender,feeReceiver,fee);
          } else {
              require(msg.value == fee,'Please send the correct number of ETH');
              IWETH(weth).deposit{value: fee}();
              IWETH(weth).transfer(feeReceiver,fee);
          }
        }
        LockDetail memory lockinfo = LockDetail({
            LockTitle:_titile,
            ddl:block.number+ _unlockCycle * _unlockRound * oneDayBlock + _cliffPeriod *oneDayBlock,
            startTime : block.number,
            amount:_amount,
            unlockCycle: _unlockCycle,
            unlockRound:_unlockRound,
            token:_token,
            cliffPeriod:block.number +_cliffPeriod *oneDayBlock,
            isNotTerminate:_Terminate
        });
        ListTokenAddress.push(_token);
        tokenAddress[_to].push(_token);
        ownerLockDetail[_to].push(lockinfo);
        ListOwnerLockDetail.push(lockinfo);
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
    }
    function groupLock(address _token, uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount , address[] memory _to, uint256[] memory _rate,string memory _titile,uint256 _cliffPeriod,bool _isNotTerminate,bool _isNotChange) public payable{
      require(block.number + _unlockCycle * _unlockRound * oneDayBlock > block.number,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        uint LockId; 
        if(feeON){
            if(msg.value == 0) {
                TransferHelper.safeTransferFrom(weth,msg.sender,feeReceiver,fee);
            }else{
                require(msg.value == fee);
                IWETH(weth).deposit{value:fee}();
                IWETH(weth).transfer(feeReceiver,fee);
            }
        }
        groupLockDetail memory _groupLockDetail = groupLockDetail({
        LockTitle:_titile,
        ddl:block.number+ _unlockCycle * _unlockRound * oneDayBlock + _cliffPeriod *oneDayBlock,
        startTime:block.number,
        admin:msg.sender,
        amount:_amount,
        unlockCycle:_unlockCycle,
        unlockRound:_unlockRound,
        rate : _rate,
        token:_token,
        member:_to,
        isNotchange:_isNotChange,
        isNotTerminate:_isNotTerminate
        });
        ListTokenAddress.push(_token);
        ListGropLockDetail.push(_groupLockDetail);
        adminGropLockDetail[msg.sender].push(_groupLockDetail);
        for(uint i = 0 ; i < _to.length ; i++){
        groupMember[LockId].push(_to[i]);
        }
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
    }
     
    function TerminateLock(uint256 _lockId,address token) public {
        require(ownerLockDetail[msg.sender][_lockId].amount > 0,"you aren't have balance for lock");
        require(ownerLockDetail[msg.sender][_lockId].isNotTerminate,"!isNotTerminate");
        IERC20(token).transfer(msg.sender , ownerLockDetail[msg.sender][_lockId].amount);
        ownerLockDetail[msg.sender][_lockId].amount = 0;
    }
    function TerminateLockForGroupLock(uint256 _lockId,address token) public {
        require(msg.sender == adminGropLockDetail[msg.sender][_lockId].admin, "no access");
        require(adminGropLockDetail[msg.sender][_lockId].isNotTerminate,"!isNotTerminate");
        require(adminGropLockDetail[msg.sender][_lockId].amount > 0,"you aren't have balance for lock");
        IERC20(token).transfer(msg.sender , adminGropLockDetail[msg.sender][_lockId].amount);
    }

    function unlock(uint _index, address _token) public  {
        require(block.number >= ownerLockDetail[msg.sender][_index].cliffPeriod,"current time should be bigger than cliffPeriod");
        uint amountOfUser = ownerLockDetail[msg.sender][_index].amount;
        uint amount = IERC20(_token).balanceOf(address(this));
        if(amount > amountOfUser || amount == amountOfUser){
        IERC20(_token).transfer(
            msg.sender,
            (amountOfUser/(ownerLockDetail[msg.sender][_index].unlockCycle*ownerLockDetail[msg.sender][_index].unlockRound))*(block.number - ownerLockDetail[msg.sender][_index].startTime)/oneDayBlock);
            ownerLockDetail[msg.sender][_index].amount -=(amountOfUser/(ownerLockDetail[msg.sender][_index].unlockCycle*ownerLockDetail[msg.sender][_index].unlockRound))*(block.number - ownerLockDetail[msg.sender][_index].startTime)/oneDayBlock;
            ownerLockDetail[msg.sender][_index].startTime = block.number;
        }else{
            revert();
        }
    }

    function groupUnLock(uint256 _index ,address _token) public {
        require(checkRate(msg.sender, _index) == 100 ,"rate is error");
        require(block.number >= adminGropLockDetail[msg.sender][_index].ddl,"current time should be bigger than deadlineTime");
        uint amountOfUser = adminGropLockDetail[msg.sender][_index].amount;
        uint amount = IERC20(_token).balanceOf(address(this));
        if(amount > amountOfUser || amount == amountOfUser){
            for(uint i = 0 ; i < adminGropLockDetail[msg.sender][_index].member.length;i++){
            IERC20(_token).transfer(
                adminGropLockDetail[msg.sender][_index].member[i],
                (amountOfUser*adminGropLockDetail[msg.sender][_index].rate[i]/100)/(adminGropLockDetail[msg.sender][_index].unlockRound*adminGropLockDetail[msg.sender][_index].unlockRound)*(block.number - adminGropLockDetail[msg.sender][_index].startTime)/oneDayBlock);
                adminGropLockDetail[msg.sender][_index].amount -= (amountOfUser*adminGropLockDetail[msg.sender][_index].rate[i]/100)/(adminGropLockDetail[msg.sender][_index].unlockRound*adminGropLockDetail[msg.sender][_index].unlockRound)*(block.number - adminGropLockDetail[msg.sender][_index].startTime)/oneDayBlock;
            }
            adminGropLockDetail[msg.sender][_index].startTime = block.number;
        }else{
            revert();
            }
    }
    function checkRate(address _user, uint256 _index) public view returns(uint) {
        uint totalRate;
        for(uint i =0; i < adminGropLockDetail[_user][_index].rate.length; i++ ){
            totalRate += adminGropLockDetail[_user][_index].rate[i];
        }
        return totalRate;
    }
    function changeLockAdmin(address  _to, uint _index) public {
        if(adminAndOwner[msg.sender] == address(0)){
        require(msg.sender == adminGropLockDetail[msg.sender][_index].admin,"you are not admin");
        require(adminGropLockDetail[msg.sender][_index].isNotchange ,"you can't turn on isNotchange when you create ");
        adminGropLockDetail[msg.sender][_index].admin = _to;
        adminAndOwner[_to] = msg.sender;
        }else{
        require(msg.sender == adminGropLockDetail[adminAndOwner[msg.sender]][_index].admin,"you are not admin");
        require(adminGropLockDetail[adminAndOwner[msg.sender]][_index].isNotchange ,"you can't turn on isNotchange when you create ");
        adminGropLockDetail[adminAndOwner[msg.sender]][_index].admin = _to;
        adminAndOwner[_to] = adminAndOwner[msg.sender];
        }
    }
    function setIsNotChange(uint _index) public {
        if(adminAndOwner[msg.sender] == address(0)){
        require(msg.sender == adminGropLockDetail[msg.sender][_index].admin,"you are not admin");
        adminGropLockDetail[msg.sender][_index].isNotchange = !adminGropLockDetail[msg.sender][_index].isNotchange;
        }else{
        require(msg.sender == adminGropLockDetail[adminAndOwner[msg.sender]][_index].admin,"you are not admin");
        adminGropLockDetail[adminAndOwner[msg.sender]][_index].isNotchange = !adminGropLockDetail[adminAndOwner[msg.sender]][_index].isNotchange;
        }
    }
    function addLockMember(address _to, uint _index, uint _rate) public {

        require(msg.sender == adminGropLockDetail[msg.sender][_index].admin);
        if(adminGropLockDetail[msg.sender][_index].rate[0]-_rate > 0){
        adminGropLockDetail[msg.sender][_index].rate[0]-_rate;
        }else{
            revert();
        }
        adminGropLockDetail[msg.sender][_index].member.push(_to);
        adminGropLockDetail[msg.sender][_index].rate.push(_rate);
        groupMember[_index].push(_to);
  
    }
    function checkGroupMember(address admin, uint _index) public view returns(address[] memory){
        return adminGropLockDetail[admin][_index].member;
    }
    function setGroupMemberRate(uint _index, uint[] memory _rate) public {
        require(msg.sender == adminGropLockDetail[msg.sender][_index].admin);
        for(uint i =0; i< adminGropLockDetail[msg.sender][_index].rate.length ;i++){
        adminGropLockDetail[msg.sender][_index].rate[i] = _rate[i];
        }
    }
    function removeLockMember(address _to, uint _index) public {
        require(msg.sender == adminGropLockDetail[msg.sender][_index].admin,'no access');
        uint id;
        for(uint i = 0 ; i < adminGropLockDetail[msg.sender][_index].member.length; i++){
            if(_to == adminGropLockDetail[msg.sender][_index].member[i]){
                 id = i;
        adminGropLockDetail[msg.sender][_index].member[id] = adminGropLockDetail[msg.sender][_index].member[adminGropLockDetail[msg.sender][_index].member.length - 1];
        adminGropLockDetail[msg.sender][_index].member.pop();
            }
        }

    }

    function getLockTitle(uint _index) public view returns(string memory){
        return ownerLockDetail[msg.sender][_index].LockTitle;
    }
    function getGroupLockTitle(uint _index) public view returns(string memory) {
        return adminGropLockDetail[msg.sender][_index].LockTitle;
    }
    function getAmount(uint _index) public view returns(uint) {
        return ownerLockDetail[msg.sender][_index].amount;
    }
    function getDdl(uint _index) public view returns(uint) {
        return ownerLockDetail[msg.sender][_index].ddl;
    }

    function getTokenName(uint _index) public view returns(string memory) {
        return IERC20(ownerLockDetail[msg.sender][_index].token).name();
    }

    function getTokenSymbol(uint _index) public view returns(string memory) {
        return IERC20(ownerLockDetail[msg.sender][_index].token).symbol();
    }

    function getTokenDecimals(uint _index) public view returns(uint) {
        return IERC20(ownerLockDetail[msg.sender][_index].token).decimals();
    }

    function getToken() public view returns(address[] memory) {
        return tokenAddress[msg.sender];
    }

    function ListOwnerLockDetailLength() public view returns(uint256){
        return ListOwnerLockDetail.length;
    }
    function ListGropLockDetailLength() public view returns(uint256) {
        return ListGropLockDetail.length;
    }
}
