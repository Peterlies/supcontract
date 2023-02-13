// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./interface/IFirePassport.sol";
import "./FirePassport.sol";


contract AirdropERC1155dev is ERC1155Holder{
    IERC1155 public token;
    FirePassport fp;
    address public passport;
    address public admin;
    uint256 public id;
    uint256 public oneday = 86400;
    uint256 public endTime;
    uint256 public startTime;
    uint public num;
    mapping(address => bool) public Claimed;
    address[] public ClaimedList;
    constructor(IERC1155 _token,uint256 _tokenId, address _passport, address _admin, uint256 _startTime,uint _endTime){
        token = _token;
        id = _tokenId;
        passport = _passport;
        admin = _admin;
        startTime = _startTime;
        endTime = _endTime;
    }
    modifier onlyAdmin {
        require(msg.sender == admin ,"no access");
        _;
    }
    function changeAdmin(address _to) public onlyAdmin{
        admin = _to;
    }
    function remaining(uint256 _id) public onlyAdmin{
        token.safeTransferFrom(address(this), msg.sender,_id,get1155Balance(_id),"fire");
    }
    function setId(uint256 _id) public onlyAdmin{
        id = _id;
    }
    function addNum(uint _num) public onlyAdmin{
        num = _num;
    }
    function setStartTime(uint256 _time) public onlyAdmin {
        startTime =_time;
    }
    function setEndTime(uint256 _time) public onlyAdmin {
        endTime = _time;
    }
    function getCurrentTimeStamp() public view returns(uint256) {
        return block.timestamp;
    }
    function setPassportAddr(address payable _addr) public onlyAdmin{
        fp = FirePassport(_addr);
    }


    function Claim(uint _pid) public {
        require(IERC721(passport).balanceOf(msg.sender) !=0 ,"Insufficient balance for lock");
        require(!Claimed[msg.sender],"Insufficient balance for Claim");
        require(block.timestamp < endTime , "Insufficient time");
        require(block.timestamp > startTime, "Airdrop not started");
        if(_pid > 0 &&  _pid < 101){
            if(get1155Balance(id) < 10 && get1155Balance(id + num) > 0) {
            uint amount = get1155Balance(id);
            token.safeTransferFrom(address(this), msg.sender,id,amount,"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,10 - amount,"fire");
            }else{
            token.safeTransferFrom(address(this), msg.sender,id,10,"fire");
            }
        }else if(_pid > 100 && _pid < 201){
            if(get1155Balance(id) < 9 && get1155Balance(id) > 0) {
            uint amount = get1155Balance(id);
            token.safeTransferFrom(address(this), msg.sender,id,amount,"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,9 - amount,"fire");
            }else{
            token.safeTransferFrom(address(this), msg.sender,id,9,"fire");
            }
        }else if(_pid > 200 && _pid <301){
            if(get1155Balance(id) < 8 && get1155Balance(id) > 0) {
            uint amount = get1155Balance(id);
            token.safeTransferFrom(address(this), msg.sender,id,amount,"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,8 - amount,"fire");
            }else{
            token.safeTransferFrom(address(this), msg.sender,id,8,"fire");
            }
        }else if(_pid > 300 && _pid < 401){
            if(get1155Balance(id) < 7 && get1155Balance(id) > 0) {
            uint amount = get1155Balance(id);
            token.safeTransferFrom(address(this), msg.sender,id,amount,"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,7 - amount,"fire");
            }else{
            token.safeTransferFrom(address(this), msg.sender,id,7,"fire");
            }
        }else if(_pid > 400 && _pid <501) {
           if(get1155Balance(id) < 6 && get1155Balance(id) > 0) {
            uint amount = get1155Balance(id);
            token.safeTransferFrom(address(this), msg.sender,id,amount,"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,6 - amount,"fire");
            }else{           
            token.safeTransferFrom(address(this), msg.sender,id,6,"fire");
            }
        }else if(_pid > 500 && _pid <601) {
            if(get1155Balance(id) < 5 && get1155Balance(id) > 0) {
            uint amount = get1155Balance(id);
            token.safeTransferFrom(address(this), msg.sender,id,amount,"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,5 - amount,"fire");
            }else{           
            token.safeTransferFrom(address(this), msg.sender,id,5,"fire");
            }
        } else if(_pid > 600 && _pid < 701 ){
            if(get1155Balance(id) < 4 && get1155Balance(id) > 0) {
            uint amount = get1155Balance(id);
            token.safeTransferFrom(address(this), msg.sender,id,amount,"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,4 - amount,"fire");
            }else{           
            token.safeTransferFrom(address(this), msg.sender,id,4,"fire");
            }
        }else if(_pid > 700 && _pid < 801){
            if(get1155Balance(id) < 3 && get1155Balance(id) > 0) {
            uint amount = get1155Balance(id);
            token.safeTransferFrom(address(this), msg.sender,id,amount,"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,3- amount,"fire");
            }else{
            token.safeTransferFrom(address(this), msg.sender,id,3,"fire");
            }   
        }else if(_pid > 800 && _pid < 901){
            if(get1155Balance(id) < 2 && get1155Balance(id) > 0) {
            uint amount = get1155Balance(id);
            token.safeTransferFrom(address(this), msg.sender,id,amount,"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,2- amount,"fire");
            }else{
            token.safeTransferFrom(address(this), msg.sender,id,2,"fire");
            }
        }else if(_pid > 900 && _pid < 1001){
            if(get1155Balance(id) == 0){
            token.safeTransferFrom(address(this), msg.sender,id + num ,1,"fire");
            }else{
            token.safeTransferFrom(address(this), msg.sender,id,1,"fire");
            }
        }else{
           return; 
        }
    Claimed[msg.sender] = true;
    ClaimedList.push(msg.sender);
    }
    function get1155Balance(uint256 _id) public view returns(uint256) {
        return token.balanceOf(address(this),_id);
    }
    function getPid(address _user) public view returns(uint256,address,string memory,string memory,uint256){
        return fp.userInfo(_user);
    }
}
