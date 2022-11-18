// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";


interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}



contract LockFactory is Ownable{
    address public newLock;
    address public newgLock;

    mapping (address => address) public ownerOfLock;
    mapping (address => address) public groupOfLock;
    function createNewLock(address _token,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile,address _user) public {

        address lock = address(new FireLock( _token,_unlockCycle, _unlockRound , _amount, _cliffPeriod , _titile,_user));
        newLock = lock;
        IERC20(_token).transferFrom(msg.sender,newLock,_amount);
        ownerOfLock[msg.sender] = lock;
    }

    function createNewGroupLock(address _token, uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount , address[] memory _to, uint256[] memory _rate,string memory _titile,uint256 _cliffPeriod,address _createUser) public {

        address glock = address(new groupLock(_token,_unlockCycle,_unlockRound,_amount,_to,_rate,_titile,_cliffPeriod,_createUser));
        newgLock = glock;
        IERC20(_token).transferFrom(msg.sender,newgLock,_amount);
        groupOfLock[msg.sender] = glock;
    }
}

contract FireLock {
    
    struct LockDetail{
        string LockTitle;
        uint256 ddl;
        uint256 startTime;
        uint256 amount;
        uint256 unlockCycle;
        uint256 unlockRound;
        address token;
        uint256 cliffPeriod;
    }
    // address public feeTo;
    // uint256 public fee;
    mapping(address => address[]) tokenAddress;
    mapping(address => LockDetail[]) public ownerLockDetail;

constructor(address _token,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile,address _user) {
    lock( _token,_unlockCycle, _unlockRound , _amount, _cliffPeriod , _titile,_user);
}


    function lock(address _token,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile,address _user) public  {
        require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        
        // address owner = msg.sender;
        LockDetail memory lockinfo = LockDetail({
            LockTitle:_titile,
            ddl:block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400,
            startTime : block.timestamp,
            amount:_amount,
            unlockCycle: _unlockCycle,
            unlockRound:_unlockRound,
            token:_token,
            cliffPeriod:block.timestamp +_cliffPeriod *86400
        });

        // LockDetail memory lockDetail = ownerLockDetail[msg.sender][(ownerLockDetail[msg.sender]).length];
        // lockDetail.ddl =block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400;
        // lockDetail.amount = amount;
        // lockDetail.token = _token; 
        // lockDetail.unlockCycle = _unlockCycle;
        // lockDetail.unlockRound = _unlockRound;
        // lockDetail.cliffPeriod = block.timestamp +_cliffPeriod *86400 ;
        // lockDetail.startTime = block.timestamp;
        tokenAddress[_user].push(_token);
        ownerLockDetail[_user].push(lockinfo);
        // if(msg.value == fee){
        // payable(feeTo);
        // }else{
        //     revert();
        // }
        // IERC20(_token).transferFrom(owner,address(this),_amount);
    }
        function unlock(address _token, uint256 index) public{
      
        require(block.timestamp >= ownerLockDetail[msg.sender][index].cliffPeriod,"current time should be bigger than cliffPeriod");
        uint amountOfUser = ownerLockDetail[msg.sender][index].amount;
        uint amount = IERC20(_token).balanceOf(address(this));
        if(amount > amountOfUser){
        IERC20(_token).transfer(msg.sender, (amountOfUser/(ownerLockDetail[msg.sender][index].unlockCycle*ownerLockDetail[msg.sender][index].unlockRound))*(block.timestamp-ownerLockDetail[msg.sender][index].startTime)/86400);
        }else{revert();}
    }


}

contract groupLock{

    bool alreadyChange;

    mapping(address => bool) isChangedOwner;

    mapping(address => address) adminAndOwner;


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
        address[] mumber;
        bool isNotchange;
    }
    mapping(uint256 => address[]) groupMumber;
    mapping(uint256 => address[]) groupTokenAddress;
    mapping(address => uint256[]) public UsergroupLockNum;
    mapping(address => groupLockDetail[]) public adminGropLockDetail;



    constructor(address _token, uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount , address[] memory _to, uint256[] memory _rate,string memory _titile,uint256 _cliffPeriod,address _createUser) {
            groupUserLock(_token,_unlockCycle,_unlockRound,_amount,_to,_rate,_titile,_cliffPeriod,_createUser);
    }

    function groupUserLock(address _token, uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount , address[] memory _to, uint256[] memory _rate,string memory _titile,uint256 _cliffPeriod,address _createUser) public {
      require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        uint LockId; 
        groupLockDetail memory _groupLockDetail = groupLockDetail({
        LockTitle:_titile,
        ddl:block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400,
        startTime:block.timestamp,
        admin:_createUser,
        amount:_amount,
        unlockCycle:_unlockCycle,
        unlockRound:_unlockRound,
        rate : _rate,
        token:_token,
        mumber:_to,
        isNotchange:false
        });
        groupTokenAddress[LockId].push(_token);
        UsergroupLockNum[_createUser].push(LockId);
        adminGropLockDetail[_createUser].push(_groupLockDetail);
        groupMumber[LockId] = _to;
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        LockId++;
    }
     function groupUnLock(address _token ,uint256 index) public {
   
        require(block.timestamp >= adminGropLockDetail[msg.sender][index].ddl,"current time should be bigger than deadlineTime");
        uint amountOfUser = adminGropLockDetail[msg.sender][index].amount;
        uint amount = IERC20(_token).balanceOf(address(this));
        if(amount > amountOfUser){
            for(uint i = 0 ; i < adminGropLockDetail[msg.sender][index].mumber.length;i++){
            IERC20(_token).transfer(adminGropLockDetail[msg.sender][index].mumber[i], (amountOfUser*adminGropLockDetail[msg.sender][index].rate[i]/100)/(adminGropLockDetail[msg.sender][index].unlockRound*adminGropLockDetail[msg.sender][index].unlockRound)*(block.timestamp - adminGropLockDetail[msg.sender][index].startTime)/86400);
            }
        }else{revert();}
    }
       function changeLockAdmin(address  _to, uint _index) public {
        require(msg.sender == adminGropLockDetail[msg.sender][_index].admin,"you are not admin");
        require(!isChangedOwner[_to], "you already change");
        require(adminGropLockDetail[msg.sender][_index].isNotchange ,"you can't turn on isNotchange when you create ");
        adminGropLockDetail[msg.sender][_index].admin = _to;
        adminAndOwner[_to] = msg.sender;
        alreadyChange =true;
        isChangedOwner[_to] = alreadyChange;
        
    }
    function changeLockNumber(address[] memory _to, uint _index) public {
        if(!isChangedOwner[msg.sender]){
        require(msg.sender == adminGropLockDetail[msg.sender][_index].admin);
        adminGropLockDetail[msg.sender][_index].mumber = _to;
        adminGropLockDetail[adminAndOwner[msg.sender]][_index].mumber = _to;
        }else{
        require(msg.sender == adminGropLockDetail[adminAndOwner[msg.sender]][_index].admin, "you are not admin");
        adminGropLockDetail[adminAndOwner[msg.sender]][_index].mumber = _to;
    }
}

}