// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./CityNodeTreasury.sol";
import "./interface/IFireSoul.sol";
import "./interface/IReputation.sol";

contract cityNode is ERC1155, Ownable {
    struct cityNodeInFo{
        uint256 cityNodeId;
        string cityNodeName;
        address cityNodeOwner;
        uint256 createTime;
        address[] member;
        address Treasury;
    }
    struct joinCityNodeMemberInfo{
        uint256 cityNodeId;
        uint256 joinCityNodeTime;
    }
    bool public contractStatus; 
    IERC20 public FDToken;
    address public fdTokenAddress;
    uint256 public ctiyNodeId;
    address public pauseAddress;
    address public  marketValueManager;
    address public AutoAddLPAddress;
    address public EcologicalIncomeDividendAddress;
    address public fireSoul;
    address public Reputation;
    uint[] public WeightFactor;
    uint[] public cable;
    mapping(address => uint256) public reputationPoints;
    mapping(address => bool) public isCityNodeUser;
    mapping(uint256 => bool) public isNotLightCity;
    mapping(address => bool) public cityNodeCreater;
    mapping(uint256 => address[]) public cityNodeMember;
    mapping(address => uint256) public CityNodeUserNum;
    mapping(address => joinCityNodeMemberInfo[]) public NumberInfo;
    mapping(address => string) public proposal;
    mapping(uint256 => uint256) public cityNodeFund;
    mapping(address => uint256) public userTax;
    mapping(uint => uint) public cityNodeRank;
    cityNodeInFo[] public cityNodeInFos;
    joinCityNodeMemberInfo[] public joinCityNodeMemberInfos;
    constructor() ERC1155("test") {
    }
    //external
    function checkIsCityNode(address account , uint256 amount) external  returns(bool) {
        require(msg.sender == fdTokenAddress,"call back error");
        userTax[account] = amount + userTax[account];
        return isCityNodeUser[account]; 
    }
    function checkCityNodeAmount(uint cityNodeNum)external view returns(uint256){
        require(isCityNodeUser[msg.sender], "you are not citynode user");
        uint256 totalAmountOfCityNode = 0;
        for(uint i = 0 ; i < cityNodeMember[cityNodeNum].length ; i++){
            totalAmountOfCityNode = userTax[cityNodeMember[cityNodeNum][i]] + totalAmountOfCityNode ;
        }
        return totalAmountOfCityNode;
    }
    function setPause() external  {
        require(msg.sender == pauseAddress,"callback address is not pauseAddress");
        contractStatus = !contractStatus;   
    }
    //onlyOwner
    function setFdTokenAddress(address _fdTokenAddress) public onlyOwner{
        fdTokenAddress = _fdTokenAddress;
    }
    function setReputationAddress(address _Reputation) public onlyOwner{
        Reputation = _Reputation;
    }
    function setFireSoulAddress(address _fireSoul) public onlyOwner{
        fireSoul = _fireSoul;
    }

    function setPause(address _pauseAddress) public onlyOwner{
        pauseAddress = _pauseAddress;
    }
   
    function setReputationPointsAddress(IERC20 _FDToken) public onlyOwner{
        FDToken = _FDToken;
    }
    function addWeightFactor(uint _WeightFactorNum, uint _WeightFactor) public onlyOwner{
        WeightFactor[_WeightFactorNum] = _WeightFactor;
    }
   function setMarketValueManagerAddress( address _MarketValueAddress) public onlyOwner {
        marketValueManager = _MarketValueAddress;
    }
    function setAutoAddLPAddress(address _AutoAddLPAddress) public onlyOwner{
        AutoAddLPAddress = _AutoAddLPAddress;
    }
    function setEcologicalIncomeDividendAddress(address _EcologicalIncomeDividendAddress) public onlyOwner{
        EcologicalIncomeDividendAddress = _EcologicalIncomeDividendAddress;
    }
    //view
    function checkWeightFactorLength() public view returns(uint256){
        return WeightFactor.length;
    }
    function checkReputationPoints() public view returns(uint256) {
        return FDToken.balanceOf(msg.sender);
    }

    function checkCityNodeQuantity() public view returns(uint256){
        return cityNodeInFos.length;
    }
    function checkCityNodeId() public view returns(uint256) {
        return CityNodeUserNum[msg.sender];
    }
    //main
    function createCityNode(uint256 cityNodeNum,string memory cityNodeName) public {
        require(IFireSoul(fireSoul).checkFID(msg.sender) , "you haven't FID,plz burn fireseed to create"); 
        require(!contractStatus,"Status is false");
        require(IReputation(Reputation).checkReputation(msg.sender) > 100000*10*18,"not enough");
        require(cityNodeNum <= ctiyNodeId, "the cityNode has been created");
        address nodeTreasury = address(new CityNodeTreasury());
        _mint(msg.sender,ctiyNodeId,1,"test");
         cityNodeCreater[msg.sender] = true;
         cityNodeMember[cityNodeNum].push(msg.sender);
         CityNodeUserNum[msg.sender] = cityNodeNum;
         cityNodeInFo memory Info = cityNodeInFo(ctiyNodeId, cityNodeName,msg.sender,block.timestamp,cityNodeMember[cityNodeNum],nodeTreasury);
         cityNodeInFos.push(Info);
         ctiyNodeId++;
    }
    function joinCityNode(uint256 cityNodeNum) public {
        require(!contractStatus,"Status is false");
        require(IFireSoul(fireSoul).checkFID(msg.sender) , "you haven't FID,plz burn fireseed to create"); 
        require(cityNodeCreater[msg.sender] == false, "you are already a creator");
        require(isCityNodeUser[msg.sender] == false, "you are already join a cityNode");
        require(cityNodeNum > ctiyNodeId, "you input error");
        _mint(msg.sender,cityNodeNum,1,"test");
        cityNodeMember[cityNodeNum].push(msg.sender);
        CityNodeUserNum[msg.sender] = cityNodeNum;
        joinCityNodeMemberInfo memory Info = joinCityNodeMemberInfo( cityNodeNum,block.timestamp);
        joinCityNodeMemberInfos.push(Info);
        isCityNodeUser[msg.sender] = true;
        cityNodeMember[cityNodeNum].push(msg.sender);
        NumberInfo[msg.sender] = joinCityNodeMemberInfos;
        
    }
    function deleteCityNodeUser(address _nodeUser) public {
        require(!contractStatus,"Status is false");
        require(cityNodeCreater[msg.sender] == true, "you are not a owner");
        _burn(_nodeUser, CityNodeUserNum[msg.sender], 1);
    }
    function quitCityNode() public{
        require(!contractStatus,"Status is false");
        require(isCityNodeUser[msg.sender] == true,"you haven't join any citynode");
        _burn(msg.sender,CityNodeUserNum[msg.sender],1);
        isCityNodeUser[msg.sender] = false;
    }
    function lightCityNode() public {
        require(!contractStatus,"Status is false");
        uint total;
        for(uint i = 0;i < cityNodeMember[CityNodeUserNum[msg.sender]].length; i++){
        total += IReputation(Reputation).checkReputation(cityNodeMember[CityNodeUserNum[msg.sender]][i]); 
        if(total >= 1000000 *10**18){
            isNotLightCity[CityNodeUserNum[msg.sender]] = true;
        }
        }
    }
    function createCityNodeProposal(string memory _proposal) public {
        require(!contractStatus,"Status is false");
        require(isCityNodeUser[msg.sender] == true,"you haven't join any citynode");
        require(IReputation(Reputation).checkReputation(msg.sender) > 100000*10*18,"you reputation point not enough");
        require(block.timestamp - NumberInfo[msg.sender][CityNodeUserNum[msg.sender]].joinCityNodeTime > 2678400,"you haven't make a proposal" );
        proposal[msg.sender] = _proposal;
    }

      function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(from == msg.sender && to == msg.sender, "not to transfer");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }
    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(from == msg.sender && to == msg.sender, "not to transfer");

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}