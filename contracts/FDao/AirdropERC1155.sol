// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interface/IFirePassport.sol";
contract AirdropERC1155 {
    IERC1155 public token;
    address public passport;
    address public admin;
    uint256 public id;
    uint public num;
    constructor(IERC1155 _token, address _passport, address _admin){
        token = _token;
        passport = _passport;
        admin = _admin;
    }
    modifier onlyAdmin {
        require(msg.sender == admin ,"no access");
        _;

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
    function Claim() public {
        require(IERC721(passport).balanceOf(msg.sender) !=0 ,"Insufficient balance for lock");
        if(getPid(msg.sender) > 0 &&  getPid(msg.sender) < 101){
            if(get1155Balance(id) < 10 && get1155Balance(id) > 0) {
            token.safeTransferFrom(address(this), msg.sender,id,get1155Balance(id),"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,10 - get1155Balance(id),"fire");
            }           
            token.safeTransferFrom(address(this), msg.sender,1,10,"fire");
        }else if(getPid(msg.sender) > 100 && getPid(msg.sender) <201){
            if(get1155Balance(id) < 9 && get1155Balance(id) > 0) {
            token.safeTransferFrom(address(this), msg.sender,id,get1155Balance(id),"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,9 - get1155Balance(id),"fire");
            }           
            token.safeTransferFrom(address(this), msg.sender,id,9,"fire");
        }else if(getPid(msg.sender) > 200 && getPid(msg.sender) <301){
       if(get1155Balance(id) < 8 && get1155Balance(id) > 0) {
            token.safeTransferFrom(address(this), msg.sender,id,get1155Balance(id),"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,8 - get1155Balance(id),"fire");
            }           
            token.safeTransferFrom(address(this), msg.sender,id,8,"fire");
        }else if(getPid(msg.sender) > 300 && getPid(msg.sender) < 401){
       if(get1155Balance(id) < 7 && get1155Balance(id) > 0) {
            token.safeTransferFrom(address(this), msg.sender,id,get1155Balance(id),"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,7 - get1155Balance(id),"fire");
            }           
            token.safeTransferFrom(address(this), msg.sender,id,7,"fire");
        }else if(getPid(msg.sender) > 400 && getPid(msg.sender) <501) {
           if(get1155Balance(id) < 6 && get1155Balance(id) > 0) {
            token.safeTransferFrom(address(this), msg.sender,id,get1155Balance(id),"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,6 - get1155Balance(id),"fire");
            }           
            token.safeTransferFrom(address(this), msg.sender,id,6,"fire");
        }else if(getPid(msg.sender) > 500 && getPid(msg.sender) <601) {
            if(get1155Balance(id) < 5 && get1155Balance(id) > 0) {
            token.safeTransferFrom(address(this), msg.sender,id,get1155Balance(id),"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,5 - get1155Balance(id),"fire");
            }           
            token.safeTransferFrom(address(this), msg.sender,id,5,"fire");

        } else if(getPid(msg.sender) > 600 && getPid(msg.sender) < 701 ){
            if(get1155Balance(id) < 4 && get1155Balance(id) > 0) {
            token.safeTransferFrom(address(this), msg.sender,id,get1155Balance(id),"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,4 - get1155Balance(id),"fire");
            }           
            token.safeTransferFrom(address(this), msg.sender,id,7,"fire");

        }else if(getPid(msg.sender) > 700 && getPid(msg.sender) < 801){
            if(get1155Balance(id) < 3 && get1155Balance(id) > 0) {
            token.safeTransferFrom(address(this), msg.sender,id,get1155Balance(id),"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,3 - get1155Balance(id),"fire");
            }           
            token.safeTransferFrom(address(this), msg.sender,id,3,"fire");

        }else if(getPid(msg.sender) > 800 && getPid (msg.sender) < 901){
            if(get1155Balance(id) < 2 && get1155Balance(id) > 0) {
            token.safeTransferFrom(address(this), msg.sender,id,get1155Balance(id),"fire");
            token.safeTransferFrom(address(this), msg.sender,id + num ,2 - get1155Balance(id),"fire");
            }           
            token.safeTransferFrom(address(this), msg.sender,id,2,"fire");

        }else if(getPid(msg.sender) > 900 && getPid(msg.sender) < 1001){
            token.safeTransferFrom(address(this), msg.sender,id,1,"fire");

        }else{
           return; 
        }

    }
    function get1155Balance(uint256 _id) public view returns(uint256) {
        return token.balanceOf(address(this),_id);
    }
    function getPid(address _user) public view returns(uint){
        return IFirePassport(passport).getUserInfo(_user).PID;
    }
}
