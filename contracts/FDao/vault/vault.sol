pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


contract valut {

    address public owner;
    address public rbd;
    address public admin; 

    string public name;
    string public intro;
    string public logo;

    uint public time ;
    uint public index;
    uint public index1;
    uint public index2;
    

    mapping(address=>bool)status;
    mapping(address=> userInfo) info;

    struct userInfo{
        //uint id;
        string valut;
        address valutAddress;
        address user;
        uint amount;
        uint time;
    }
    userInfo[]public list2;
    mapping(address=>AlertPayRule) alertPayRules;
    struct AlertPayRule{
        uint completeClosurePeriod ;
        uint ReleasePeriod;
        uint monthlyReleaseRatio;
        uint AlertPayDayRule;
    }
    //mapping (address=>certigierInfo) certigier;
    mapping (address=>uint) amounts;
    struct withdrawalInfo{
        address owner;
        uint time;
        uint amount;
    }
    withdrawalInfo[]public list;
    struct manageinfo{
       address owner;
       uint proportion;
       bool pause;
       bool termination;
   }
   manageinfo[]public list3;

    event Withdraw(address to, uint amount,bool choose);
    event Deposit(address addr,address to, uint amount);
    event CreatVault(string name,string intro,string logo,uint completeClosurePeriod,uint monthlyReleaseRatio,uint AlertPayDayRule);
    
    
    constructor(address manager)  {
        admin = manager;
    }
    
    modifier  _isOwner() {
        require(msg.sender == admin);
        _;
    }
    
    function creatVault(string memory _name,string memory _intro,string memory _logo,uint completeClosurePeriod,uint ReleasePeriod,uint monthlyReleaseRatio,uint AlertPayDayRule)public{
        owner=msg.sender;
        name=_name;
        intro=_intro;
        logo=_logo;
        AlertPayRule memory info1= AlertPayRule({
      
            completeClosurePeriod:24,
            ReleasePeriod:ReleasePeriod,
            monthlyReleaseRatio:monthlyReleaseRatio,
            AlertPayDayRule:AlertPayDayRule

        });
        
    }
    
    function deposit(address rbd, uint amount ) public {
        uint32 blockTime=uint32(block.timestamp % 2 ** 32);
        uint userBalance=IERC20(rbd).balanceOf(msg.sender);

        //require (amount<=userBalance,"There aren't enough tokens");
        index=index+1; 
        IERC20(rbd).transferFrom(msg.sender,address(this),amount);
        time=blockTime;
        userInfo memory userinfo=userInfo({
            //id: id,
            valut:name,
            valutAddress:address(this),
            user:msg.sender,
            amount:amount,
            time:blockTime
        });
        list2.push(userinfo);
    }

    function withdraw(address rbd,address to ,uint amount,uint number)public{
         
        index1=index1+1;
         if (msg.sender==to){
            uint32 blockTime = uint32(block.timestamp % 2 ** 32);
            if(number==1){
               // IERC20(rbd).transferFrom(address(this),msg.sender,amount);
                withdrawalInfo memory infos=withdrawalInfo({
                    owner:to,
                    time:blockTime,
                    amount:amount
                });
                list.push(infos);
                
            }
            if (number==2){
                if(alertPayRules[address(this)].AlertPayDayRule==0){
                    uint amounts=(((blockTime-time)/86400)*alertPayRules[address(this)].monthlyReleaseRatio/100)*info[msg.sender].amount;
                     //amounts=(userInfo.amonut/1000)*((blockTime-time)/86400);
                    require(amount<=amounts,"Exceeds withdrawal amount");
                     IERC20(rbd).transfer(to,amount);
                }
                if (alertPayRules[address(this)].AlertPayDayRule!=0){
                    uint amounts=((blockTime-time)/2592000)*alertPayRules[address(this)].AlertPayDayRule*info[msg.sender].amount;
                    require(amount<=amounts,"Exceeds withdrawal amount");
                    IERC20(rbd).transfer(to,amount);
                }
            }
        }
        else{
            require(status[to]==true,"not authorized");
            require(amount <=list2[index].amount*amounts[to]);
            uint32 blockTime = uint32(block.timestamp % 2 ** 32);
            uint time2=info[to].time+(alertPayRules[address(this)].completeClosurePeriod+alertPayRules[address(this)].ReleasePeriod)*2592000;
            require(blockTime>=time2);  
            IERC20(rbd).transfer(to,amount);
            // uint balance=IERC20(rbd).balanceOf(address(this));
            // reserve =balance ;                                                                                                                                                                                     
        }
    }
    

    function getBanlance()public view returns(uint){
        return list2[0].amount;
    }

    function getName()public view returns(string memory ){
        return name;
    }

    function cancelApprove(address to )public{
        list3[index2].pause==false;
    }

    function approves(address to,uint rate)public{
        index2=index2+1;
        //require(msg.sender==owner);
        //require(msg.sender !=to);
        manageinfo memory info=manageinfo({
            owner:to,
            proportion:rate,
            pause:true,
            termination:true
        });
        list3.push(info);
    }

    function getAlertPayRule()public view returns(AlertPayRule memory){
        return alertPayRules[address(this)];
    }

    
   function depositAmount()public view returns(uint){
       return list2[index].amount;
       
   }
}