// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./CityNodeTreasury.sol";

interface IMinistryOfFinance {
  function AllocationFund() external ;
}
interface IFidPromotionCompetition{
    function distribute() external;
}
interface CityNodePromotionCompetition{
   function TotalDistributeAward_week(address citynodeUser) external;
}
interface IAutoAddLP{
    function addlP(address user) external ;
}
interface IEcologicalincomeDividend{
    function Dividend(address user) external ;
}

contract cityNode is ERC1155, Ownable {
    bool public contractStatus = true; 
    IERC20 public FDToken;
    IERC20[] public SBT;
    IERC721 public FID;
    uint256 public ctiyNodeId;
    address public  marketValueManager;
    address public MinistryOfFinanceAddress;
    address public FidPromotionCompetitionAddress;
    address public CityNodePromotionCompetitionAddress;
    address public AutoAddLPAddress;
    address public EcologicalIncomeDividendAddress;
    uint[] public WeightFactor = [10,15];
        uint[] public cable;

    mapping(address => uint256) public reputationPoints;
    mapping(address => bool) public isCityNodeUser;
    mapping(uint256 => bool) public isNotLightCity;
    mapping(address => bool) public cityNodeCreater;
    mapping(uint256 => address[]) public cityNodeMember;
    mapping(address => uint256) public CityNodeUserNum;
    mapping(address => joinCityNodeMemberInfo[]) public NumberInfo;
    mapping(address => string) public proposal;
    mapping(uint256 => mapping(address => uint256)) public cityNodeTotalReputationPoints;
    mapping(uint256 => uint256) public cityNodeFund;
    mapping(address => uint256) public userTax;

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
    cityNodeInFo[] public cityNodeInFos;
    joinCityNodeMemberInfo[] public joinCityNodeMemberInfos;
    constructor() ERC1155("test") {

    }

    function checkIsCityNode(address account , uint256 amount) external  returns(bool) {
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


    function setFIDServe() public view returns(uint256){
        return FID.balanceOf(msg.sender);
    }

    function setSBTAddress(IERC20[] memory _SBT) public onlyOwner {
        for ( uint i = 0; i<SBT.length;i++){
            SBT[i] = _SBT[i];
        }
    }
    function checkTotalReputationPoints()public view returns(uint256){
        uint256 t = 0;
        for(uint i = 0; i< SBT.length ; i++){
            t += SBT[i].balanceOf(msg.sender)*WeightFactor[i];
        }
        return t;
    } 
       function checkTotalReputationPointsExternal(address user)external view returns(uint256){
        uint256 t = 0;
        for(uint i = 0; i< SBT.length ; i++){
            t += SBT[i].balanceOf(user)*WeightFactor[i];
        }
        return t;
    } 
    function _checkBatchTotalReputationPoints(address[] memory user)public view returns(uint256){
        uint256 t = 0;
        for(uint i = 0; i< SBT.length ; i++){
            t += SBT[i].balanceOf(user[i])*WeightFactor[i];
        }
        return t;
    }


    function setPause() public onlyOwner {
        contractStatus = !contractStatus;   
    }
    function setFIDaddress( IERC721 _FID) public onlyOwner {
        FID = _FID;
    }
    function setReputationPointsAddress(IERC20 _FDToken) public onlyOwner{
        FDToken = _FDToken;
    }
    function checkWeightFactorLength() public view returns(uint256){
        return WeightFactor.length;
    }
    function addWeightFactor(uint _WeightFactorNum, uint _WeightFactor) public onlyOwner{
        WeightFactor[_WeightFactorNum] = _WeightFactor;
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

    function setMarketValueManagerAddress( address _MarketValueAddress) public onlyOwner {
        marketValueManager = _MarketValueAddress;
    }
    function setMinistryOfFinanceAddress(address _MinistryOfFinanceAddress) public onlyOwner{
        MinistryOfFinanceAddress = _MinistryOfFinanceAddress;
    }

    function setFidPromotionCompetitionAddress(address _FidPromotionCompetitionAddress) public onlyOwner {
        FidPromotionCompetitionAddress = _FidPromotionCompetitionAddress;
    }
    function setCityNodePromotionCompetitionAddress(address _CityNodePromotionCompetitionAddress) public onlyOwner{
        CityNodePromotionCompetitionAddress = _CityNodePromotionCompetitionAddress;
    }
    function setAutoAddLPAddress(address _AutoAddLPAddress) public onlyOwner{
        AutoAddLPAddress = _AutoAddLPAddress;
    }
    function setEcologicalIncomeDividendAddress(address _EcologicalIncomeDividendAddress) public onlyOwner{
        EcologicalIncomeDividendAddress = _EcologicalIncomeDividendAddress;
    }

    function createCityNode(uint256 cityNodeNum,string memory cityNodeName) public {
        // require(setFIDServe() == 1 , "you haven't FID,plz burn fireseed to create"); 
        // require(contractStatus,"Status is false");
        // require(checkTotalReputationPoints() > 100000*10*18,"not enough");
        // require(cityNodeNum <= ctiyNodeId, "the cityNode has been created");
        
        address nodeTreasury = address(new CityNodeTreasury());

        _mint(msg.sender,ctiyNodeId,1,"test");
         cityNodeCreater[msg.sender] = true;
         cityNodeMember[cityNodeNum].push(msg.sender);
         CityNodeUserNum[msg.sender] = cityNodeNum;
         cityNodeInFo memory Info = cityNodeInFo(ctiyNodeId, cityNodeName,msg.sender,block.timestamp,cityNodeMember[cityNodeNum],nodeTreasury);
         cityNodeInFos.push(Info);
         cityNodeTotalReputationPoints[cityNodeNum][msg.sender] = checkTotalReputationPoints();
         ctiyNodeId++;
    }

    function joinCityNode(uint256 cityNodeNum) public {
        require(contractStatus,"Status is false");
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
        cityNodeTotalReputationPoints[cityNodeNum][msg.sender] = checkTotalReputationPoints();
        
    }
    function deleteCityNodeUser(address _nodeUser) public {
        require(contractStatus,"Status is false");
        require(cityNodeCreater[msg.sender] == true, "you are not a owner");
        _burn(_nodeUser, CityNodeUserNum[msg.sender], 1);
    }
    

    function quitCityNode() public{
        require(contractStatus,"Status is false");
        require(isCityNodeUser[msg.sender] == true,"you haven't join any citynode");
        _burn(msg.sender,CityNodeUserNum[msg.sender],1);
        isCityNodeUser[msg.sender] = false;
    }
    function lightCityNode() public {
        require(contractStatus,"Status is false");
        // for(uint i = 0 ; i < )     
      if(_checkBatchTotalReputationPoints(cityNodeMember[CityNodeUserNum[msg.sender]]) >= 1000000*10**18){
          isNotLightCity[CityNodeUserNum[msg.sender]] = true;
      }else{
          return;
      }

    }
    function createCityNodeProposal(string memory _proposal) public {
        require(contractStatus,"Status is false");
        require(isCityNodeUser[msg.sender] == true,"you haven't join any citynode");
        require(checkTotalReputationPoints() > 10000*10*18,"not enough");
        require(block.timestamp - NumberInfo[msg.sender][CityNodeUserNum[msg.sender]].joinCityNodeTime > 2678400,"you haven't make a proposal" );
        proposal[msg.sender] = _proposal;
    }

    function FundAllocation() public payable {
        require(contractStatus,"Status is false");
        require(isNotLightCity[CityNodeUserNum[msg.sender]] ==true , "you cityNode don't light");
        require(cityNodeCreater[msg.sender] == true , "you are not creater");
        require(msg.value == 100000000000000000);
        payable(msg.sender).transfer(msg.value);
        
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

    //城市节点推广竞赛合约时间周期结束后调用需要FID声誉积分达到10w 
    function distributeFidPromotionCompetition() public {
        require(checkTotalReputationPoints() > 100000*10*18,"not enough");
        IFidPromotionCompetition(FidPromotionCompetitionAddress).distribute();
    }
    //查看FID推广竞赛合约每个城市的SBT003的数量筛选周榜
    function checkSBT003(uint i) public view returns(uint256) {
        uint256 SBT003Total = 0;
            for( uint j = 0 ; i <cityNodeMember[i].length; j++  ){
             SBT003Total += SBT[2].balanceOf(cityNodeMember[i][j]);
            }
        return SBT003Total;
    }
    //查询每个成世节点的003然后安找城市节点的序号排序
    function cableCityNode() public  {
        for(uint i = 0 ; i < ctiyNodeId; i++ ){
            if(checkSBT003(i) > checkSBT003(i+1)){
                cable[i] = checkSBT003(i);
                cable[i+1] = checkSBT003(i+1);
            }else if(checkSBT003(i) == checkSBT003(i+1)){
                cable[i] = checkSBT003(i);
                cable[i+1] = checkSBT003(i+1);
            }else{
                 cable[i] = checkSBT003(i+1);
                cable[i+1] = checkSBT003(i);
            }
        }
    }
    //
    function DistributionOfBonuses() public {
        
    }
    //城市节点排行榜
    mapping(uint => uint) public cityNodeRank;

    function checkFidReputation() public {
        for(uint j = 0 ; j <= ctiyNodeId; j++){
        for(uint i = 0 ; i <= ctiyNodeId ; i++){
        _checkBatchTotalReputationPoints(cityNodeMember[i]);
        if(_checkBatchTotalReputationPoints(cityNodeMember[i]) > _checkBatchTotalReputationPoints(cityNodeMember[i+1])){
            cityNodeRank[j] = _checkBatchTotalReputationPoints(cityNodeMember[i]);
            cityNodeRank[j+1] = _checkBatchTotalReputationPoints(cityNodeMember[i+1]);
        }else{     
            cityNodeRank[j] = _checkBatchTotalReputationPoints(cityNodeMember[i+1]);
            cityNodeRank[j+1] = _checkBatchTotalReputationPoints(cityNodeMember[i]);
        }
        }
    }
    }
    //城市节点推广竞赛合约分配奖励方法
    function DistributionOfBonusesOfCityNode() public payable {
        require(checkTotalReputationPoints() > 100000*10*18,"not enough");

        for(uint i = 0 ; i<=49 ;i ++) {
            for(uint j = 0 ; j< cityNodeMember[cityNodeRank[i]].length; j++){
        CityNodePromotionCompetition(CityNodePromotionCompetitionAddress).TotalDistributeAward_week(cityNodeMember[cityNodeRank[i]][j]);
            }
        }
        require(msg.value == 100000000000000000);
        payable(msg.sender).transfer(msg.value);
    }
    //自动回流LP方法调用
    function reflowLP() public {
        require(checkTotalReputationPoints() > 100000*10*18,"not enough");
        IAutoAddLP(AutoAddLPAddress).addlP(msg.sender);
    }
    //分红方法
    function DividendEco() public {
        for(uint j = 0 ;j < ctiyNodeId ;j ++){
        for( uint i = 0 ; i < cityNodeMember[j].length; i ++) {
        IEcologicalincomeDividend(EcologicalIncomeDividendAddress).Dividend(cityNodeMember[j][i]);
        }
        }
    }
}