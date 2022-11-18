// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


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

interface IFireGLock{
       function initMumber(address[] memory _mumber) external;
}

contract LockFactory is Ownable{
    address public newLock;
    address public newGLock;

    mapping (address => address) public ownerOfLock;
    mapping (address => address) public groupOfLock;
    function createNewLock(address _token,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile,address _user) public {

        address lock = address(new FireLock( _token,_unlockCycle, _unlockRound , _amount, _cliffPeriod , _titile,_user));
        newLock = lock;
        IERC20(_token).transferFrom(msg.sender,newLock,_amount);
        ownerOfLock[msg.sender] = lock;
    }

     function createNewGLock(address _token,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile,address _user) public {

        address Glock = address(new FireLock( _token,_unlockCycle, _unlockRound , _amount, _cliffPeriod , _titile,_user));
        newGLock = Glock;
        IERC20(_token).transferFrom(msg.sender,newGLock,_amount);
        groupOfLock[msg.sender] = Glock;
    }
    function setMumber(address[] memory _mumber) public {
        require(groupOfLock[msg.sender] != address(0),"you haven't address Of LOCk");
        IFireGLock(groupOfLock[msg.sender]).initMumber(_mumber);
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
    function lock(address _token,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile,address _user) public payable {
        require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        
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
        tokenAddress[_user].push(_token);
        ownerLockDetail[_user].push(lockinfo);
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



contract FireGLock {
    struct LockDetail{
        string LockTitle;
        uint256 ddl;
        uint256 startTime;
        uint256 amount;
        uint256 unlockCycle;
        uint256 unlockRound;
        address token;
        uint256 cliffPeriod;
        address[] mumber;
    }
    mapping(address => address[]) tokenAddress;
    mapping(address => LockDetail[]) public ownerLockDetail;
    
    address[]  _mumber;
    uint256 public startTime;
    address public user;
constructor(address _token,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile,address  _user) {
    lock( _token,_unlockCycle, _unlockRound , _amount, _cliffPeriod , _titile,_user);
}
    function lock(address _token,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile,address _user) public payable {
        require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        
        LockDetail memory lockinfo = LockDetail({
            LockTitle:_titile,
            ddl:block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400,
            startTime : block.timestamp,
            amount:_amount,
            unlockCycle: _unlockCycle,
            unlockRound:_unlockRound,
            token:_token,
            cliffPeriod:block.timestamp +_cliffPeriod *86400,
            mumber:_mumber
        });
        tokenAddress[_user].push(_token);
        ownerLockDetail[_user].push(lockinfo);
        user = _user;
    }

    function shareUser(address[] calldata userOfLock) public {
        ownerLockDetail[msg.sender][0].mumber = userOfLock;
    }

    // function checkOwnerLockDetail(address _user) external view returns(LockDetail calldata){
    //     return ownerLockDetail[_user][0];
    // }
}
