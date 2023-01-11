// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapV2Router02.sol";
import "./CityNodeTreasury.sol";
import "./interface/IFireSoul.sol";
import "./interface/IReputation.sol";
import "./interface/ICityNodeTreasury.sol";

contract cityNode is ERC1155, Ownable {
    struct cityNodeInFo{
        uint256 cityNodeId;
        string cityNodeName;
        address cityNodeOwner;
        uint256 createTime;
        address[] member;
        address Treasury;
    }
    //fix this...
    struct joinCityNodeMemberInfo{
        uint256 cityNodeId;
        uint256 joinCityNodeTime;
    }
    IERC20 public WETH;
    bool public contractStatus; 
    IUniswapV2Router02 public uniswapV2Router;
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
    uint256 public proportion;
    mapping(address => uint256) public reputationPoints;
    mapping(address => bool) public isCityNodeUser;
    mapping(uint256 => bool) public isNotLightCity;
    mapping(address => bool) public cityNodeCreater;
    mapping(uint256 => address[]) public cityNodeMember;
    mapping(address => uint256) public cityNodeUserNum;
    mapping(address => joinCityNodeMemberInfo[]) public NumberInfo;
    mapping(address => string) public proposal;
    mapping(uint256 => uint256) public cityNodeFund;
    mapping(address => uint256) public userTax;
    mapping(uint256 => address) public cityNodeAdmin;
    mapping(uint => uint) public cityNodeRank;
    mapping(address => address) public nodeTreasuryAdmin;
    cityNodeInFo[] public cityNodeInFos;
    joinCityNodeMemberInfo[] public joinCityNodeMemberInfos;
    //0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 pancake
    //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D uniswap
    constructor() ERC1155("test") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        setProportion(1);
        WETH = IERC20(_uniswapV2Router.WETH());
    }
    //external
    function checkIsCityNode(address account , uint256 amount) external  returns(bool) {
        require(msg.sender == fdTokenAddress,"call back error");
        userTax[account] = amount + userTax[account];
        WETH.transfer(cityNodeAdmin[cityNodeUserNum[account]],amount/10*proportion);
        WETH.transfer(nodeTreasuryAdmin[account], amount/10*(10 - proportion));
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
    function setProportion(uint256 _proportion) public onlyOwner {
        proportion = _proportion;
    }
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

    function checkCityNodeQuantity() public view returns(uint256){
        return cityNodeInFos.length;
    }
    function checkCityNodeId() public view returns(uint256) {
        return cityNodeUserNum[msg.sender];
    }
    //main
    function createCityNode(uint256 cityNodeNum,string memory cityNodeName) public {
        require(IFireSoul(fireSoul).checkFID(msg.sender) , "you haven't FID,plz burn fireseed to create"); 
        require(!contractStatus,"Status is false");
        require(IReputation(Reputation).checkReputation(msg.sender) > 100000*10*18,"not enough");
        require(cityNodeNum <= ctiyNodeId, "the cityNode has been created");
        address nodeTreasury = address(new CityNodeTreasury(payable(msg.sender),address(this)));
        _mint(msg.sender,ctiyNodeId,1,"test");
         cityNodeCreater[msg.sender] = true;
         cityNodeMember[cityNodeNum].push(msg.sender);
         cityNodeUserNum[msg.sender] = cityNodeNum;
         cityNodeAdmin[cityNodeNum] = msg.sender;
         nodeTreasuryAdmin[msg.sender] = nodeTreasury;
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
        cityNodeUserNum[msg.sender] = cityNodeNum;
        joinCityNodeMemberInfo memory Info = joinCityNodeMemberInfo( cityNodeNum,block.timestamp);
        joinCityNodeMemberInfos.push(Info);
        isCityNodeUser[msg.sender] = true;
        cityNodeMember[cityNodeNum].push(msg.sender);
        NumberInfo[msg.sender] = joinCityNodeMemberInfos;
        
    }
    function changeNodeAdmin(address _to) public {
        require(!contractStatus,"Status is false");
        require(IFireSoul(fireSoul).checkFID(msg.sender) , "you haven't FID,plz burn fireseed to create"); 
        require(cityNodeCreater[msg.sender], "you are not a creator");
        require(cityNodeUserNum[_to] == cityNodeUserNum[msg.sender],"the address not join you city node");
        cityNodeAdmin[cityNodeUserNum[msg.sender]] = _to;
        cityNodeCreater[_to] = true;
        nodeTreasuryAdmin[_to] = nodeTreasuryAdmin[msg.sender];
        ICityNodeTreasury(nodeTreasuryAdmin[msg.sender]).transferOwner(msg.sender, payable(_to));
    }
    function deleteCityNodeUser(address _nodeUser) public {
        require(!contractStatus,"Status is false");
        require(cityNodeCreater[msg.sender] == true, "you are not a owner");
        require(msg.sender == cityNodeAdmin[cityNodeUserNum[msg.sender]],"you are not node admin");
        _burn(_nodeUser, cityNodeUserNum[msg.sender], 1);
        isCityNodeUser[msg.sender] = false;

    }
    function quitCityNode() public{
        require(!contractStatus,"Status is false");
        require(isCityNodeUser[msg.sender] == true,"you haven't join any citynode");
        _burn(msg.sender,cityNodeUserNum[msg.sender],1);
        isCityNodeUser[msg.sender] = false;
    }
    function lightCityNode() public {
        require(!contractStatus,"Status is false");
        uint total;
        for(uint i = 0;i < cityNodeMember[cityNodeUserNum[msg.sender]].length; i++){
        total += IReputation(Reputation).checkReputation(cityNodeMember[cityNodeUserNum[msg.sender]][i]); 
        if(total >= 1000000 *10**18){
            isNotLightCity[cityNodeUserNum[msg.sender]] = true;
        }
        }
    }
    function createCityNodeProposal(string memory _proposal) public {
        require(!contractStatus,"Status is false");
        require(isCityNodeUser[msg.sender] == true,"you haven't join any citynode");
        require(IReputation(Reputation).checkReputation(msg.sender) > 100000*10*18,"you reputation point not enough");
        require(block.timestamp - NumberInfo[msg.sender][cityNodeUserNum[msg.sender]].joinCityNodeTime > 2678400,"you haven't make a proposal" );
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