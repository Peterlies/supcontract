// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./interface/IUsers.sol";

contract Users is IUsers,ERC721URIStorage {
   mapping(address => User) public userInfo;
   mapping(string => bool) public override usernameExists;
   User[] public users;
   address public owner;
   event Register(uint  id,string  username, address  account,string email,uint joinTime);
   bool public feeOn;
   uint public fee;
   uint public minUsernameLength = 4;
   uint public maxUsernameLength = 30;
   address public admin = 0x161E76814E44072798E658B5F3cd25f1f000Ab61;
   address payable  public feeReceiver;
   constructor(address payable _feeReceiver) ERC721("Fire Passport", "Fire Passport") {
      owner = msg.sender;
      feeReceiver = _feeReceiver;
      User memory user = User({id:1,account:admin,username:"admin",information:"",joinTime:block.timestamp});
      users.push(user);
      userInfo[admin] = user;
      usernameExists["admin"] = true;
      _mint(admin, 1);
   }
   modifier checkUsername(string memory username) {
       bytes memory bStr = bytes(username);
        for (uint i = 0; i < bStr.length; i++) {
            require(((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) || ((uint8(bStr[i]) >= 48) && (uint8(bStr[i]) <= 57)) || ((uint8(bStr[i]) >= 97) && (uint8(bStr[i]) <= 122)) ||(uint8(bStr[i]) == 95),'Username does not match');
        }
       _;
   }
   function register(string memory username,string memory email,string memory information,string memory tokenURI) payable external checkUsername(username) {
      string memory trueUsername = username;
      username = _toLower(username);
      require(_existsLetter(username) == true ,'Please enter at least one letter');
      require(usernameExists[username] == false,'already this user');
      require(userInfo[msg.sender].joinTime == 0,'already this user');
      require(bytes(username).length >=minUsernameLength && bytes(username).length < maxUsernameLength ,'Username length error');
      if(feeOn){
         require(msg.value == fee);
         feeReceiver.transfer(fee);
      }
      uint id = users.length + 1;
      User memory user = User({id:id,account:msg.sender,username:username,information:information,joinTime:block.timestamp});
      users.push(user);
      userInfo[msg.sender] = user;
      usernameExists[username] = true;
      _mint(msg.sender, id);
      _setTokenURI(id, tokenURI);
      emit Register(id,trueUsername,msg.sender,email,block.timestamp);
   }
   function changeUserInfo(string memory information) external {
      require(userInfo[msg.sender].id != 0,'This user does not exist');
      User storage user = userInfo[msg.sender];
      user.information = information;
      users[user.id - 1].information = information;
   }
   function getUserCount() external view override returns(uint) {
      return users.length;
   }
   function setFee(uint fees) public {
      require(msg.sender == owner ,'no access');
      require(fees <= 100000000000000000,'The maximum fee is 0.1ETH');
      fee = fees;
   }
   function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
   function setFeeOn(bool set) public {
     require(msg.sender == owner ,'no access');
      feeOn = set;
   }
   function setUsernameLimitLength(uint min,uint max) public {
      require(msg.sender == owner ,'no access');
      minUsernameLength = min;
      maxUsernameLength = max;
   }
   function changeFeeReceiver(address payable receiver) external {
      require(msg.sender == owner ,'no access');
      feeReceiver = receiver;
   }
   function changeOwner(address account) public {
      require(msg.sender == owner ,'no access');
      owner = account;
   }
   function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override  {
       from;
       to;
       tokenId;
       revert("ERC721:No transfer allowed");
    }
   function _existsLetter(string memory username) internal pure  returns(bool)  {
       bytes memory bStr = bytes(username);
        for (uint i = 0; i < bStr.length; i++) {
            if ((uint8(bStr[i]) >= 97) && (uint8(bStr[i]) <= 122)) {
               return true;
            }
        }
        return false;
   }
     receive() external payable {}
}
