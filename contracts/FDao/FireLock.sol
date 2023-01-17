// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./interface/IERC20ForLock.sol";
import "./interface/IWETH.sol";
import "./lib/TransferHelper.sol";
contract FireLock {
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
    bool public feeON;
    address public feeTo;
    uint256 public fee;
    address public feeReceiver;
    address public admin;
    address public weth;
    address public treasuryDistributionContract;
   uint256 public oneDayBlock = 7200;
    mapping(address => address[]) tokenAddress;
    mapping(address => LockDetail[]) public ownerLockDetail;
    mapping(uint256 => address[]) public groupMumber;
    mapping(uint256 => address[]) groupTokenAddress;
    mapping(address => groupLockDetail[]) public adminGropLockDetail;
    mapping(address => address) adminAndOwner;
    bool alreadyChange;
    mapping(address => uint256[]) public UsergroupLockNum;
    modifier onlyAdmin{
        require(msg.sender == admin ,"you are not the lock owner");
        _;
    }
    //0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 pancake
    //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D uniswap

    constructor(address _weth) {
        admin = msg.sender;
        weth = _weth;
    }
    function setFee(uint256 _fee) public onlyAdmin {
        require(_fee < 100000000000000000);
        fee = _fee;
    }
    function setFeeOn() public onlyAdmin {
        feeON=!feeON;
    }
    function lock(address _token,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile , bool _Terminate) public payable  {
        require(block.number + _unlockCycle * _unlockRound * oneDayBlock > block.number,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        address owner = msg.sender;
        if(feeON) {
            if(msg.value == 0){
                TransferHelper.safeTransferFrom(weth, msg.sender,feeReceiver,fee);
            }else{
                IWETH(weth).deposit{value:fee}();
                IWETH(weth).transfer(feeReceiver, fee);
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
        tokenAddress[msg.sender].push(_token);
        ownerLockDetail[msg.sender].push(lockinfo);
        IERC20(_token).transferFrom(owner,address(this),_amount);
    }

    function lockOthers(address _token,address _to,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile , bool _Terminate) public payable{
        require(block.number + _unlockCycle * _unlockRound * oneDayBlock > block.number,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        address owner = msg.sender;
        if(feeON) {
            if(msg.value == 0 ) {
                TransferHelper.safeTransferFrom(weth,msg.sender,feeReceiver,fee);
            }else{
                IWETH(weth).deposit{value:fee};
                IWETH(weth).transfer(feeReceiver, fee);
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

        tokenAddress[_to].push(_token);
        ownerLockDetail[_to].push(lockinfo);
        IERC20(_token).transferFrom(owner,address(this),_amount);
    }
      function groupLock(bool _isNotchange,address _token, uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount , address[] memory _to, uint256[] memory _rate,string memory _titile,uint256 _cliffPeriod,bool _isNotTerminate) public payable {
      require(block.number + _unlockCycle * _unlockRound * oneDayBlock > block.number,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        if(feeON){
            if(msg.value == 0) {
                TransferHelper.safeTransferFrom(weth,msg.sender,feeReceiver,fee);

            }else {
                IWETH(weth).deposit{value:fee}();
                IWETH(weth).transfer(feeReceiver,fee);
            }
        }
        uint LockId; 
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
        isNotchange:_isNotchange,
        isNotTerminate:_isNotTerminate
        });
        groupTokenAddress[LockId].push(_token);
        UsergroupLockNum[msg.sender].push(LockId);
        adminGropLockDetail[msg.sender].push(_groupLockDetail);
        groupMumber[LockId] = _to;
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        LockId++;
    }
    function TerminateLock(uint256 _lockId,address token) public {
        require(ownerLockDetail[msg.sender][_lockId].isNotTerminate,"!isNotTerminate");
        IERC20(token).transfer(msg.sender , ownerLockDetail[msg.sender][_lockId].amount);
    }
  function TerminateLockForGroupLock(uint256 _lockId,address token) public {
        require(adminGropLockDetail[msg.sender][_lockId].isNotTerminate,"!isNotTerminate");
        IERC20(token).transfer(msg.sender , adminGropLockDetail[msg.sender][_lockId].amount);
    }

    function unlock(uint _index,address _token) public  {
        
        require(block.number >= ownerLockDetail[msg.sender][_index].cliffPeriod,"current time should be bigger than cliffPeriod");
        uint amountOfUser = ownerLockDetail[msg.sender][_index].amount;
        uint amount = IERC20(_token).balanceOf(address(this));
        if(amount > amountOfUser){
        IERC20(_token).transfer(msg.sender, (amountOfUser/(ownerLockDetail[msg.sender][_index].unlockCycle*ownerLockDetail[msg.sender][_index].unlockRound))*(block.number - ownerLockDetail[msg.sender][_index].startTime)/oneDayBlock);
        }else{revert();}
    }

    function groupUnLock(uint _index,address _token) public {
        require(block.number >= adminGropLockDetail[msg.sender][_index].ddl,"current time should be bigger than deadlineTime");
        uint amountOfUser = adminGropLockDetail[msg.sender][_index].amount;
        uint amount = IERC20(_token).balanceOf(address(this));
        if(amount > amountOfUser){
            for(uint i = 0 ; i < adminGropLockDetail[msg.sender][_index].member.length;i++){
            IERC20(_token).transfer(adminGropLockDetail[msg.sender][_index].member[i], (amountOfUser*adminGropLockDetail[msg.sender][_index].rate[i]/100)/(adminGropLockDetail[msg.sender][_index].unlockRound*adminGropLockDetail[msg.sender][_index].unlockRound)*(block.number - adminGropLockDetail[msg.sender][_index].startTime)/oneDayBlock);
            }
        }else{revert();}
    }
    function changeLockAdmin(address  _to, uint _index) public {
        require(msg.sender == adminGropLockDetail[msg.sender][_index].admin,"you are not admin");
        require(adminGropLockDetail[msg.sender][_index].isNotchange ,"you can't turn on isNotchange when you create ");
        adminGropLockDetail[msg.sender][_index].admin = _to;
        adminAndOwner[_to] = msg.sender;
    }
    function addLockMember(uint _index,address _to) public {
        require(msg.sender == adminGropLockDetail[msg.sender][_index].admin);
        adminGropLockDetail[msg.sender][_index].member .push( _to);
    }
    function removeLockMember(uint _index, address _to) public {
        require(msg.sender == adminGropLockDetail[msg.sender][_index].admin);
        for(uint i = 0; i < adminGropLockDetail[msg.sender][_index].member.length; i++){
            if(_to == adminGropLockDetail[msg.sender][_index].member[i]){
                uint id = i;
                adminGropLockDetail[msg.sender][_index].member[id] = adminGropLockDetail[msg.sender][_index].member[adminGropLockDetail[msg.sender][_index].member.length -1];
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
}
