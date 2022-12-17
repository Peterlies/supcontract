// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/ISbt003.sol";
import "./interface/IFireSeed.sol";

contract FireSeed is ERC1155 ,DefaultOperatorFilterer, Ownable{

    using Counters for Counters.Counter;
    Counters.Counter private _idTracker;

    struct accountInfo {
        bool isAccount;
        uint256 settleTime;
        uint256 incomeTime;
        uint256 incomeAmount;
        uint256 cacheAmount;
    }

    mapping(address => bool) public isRecommender;
    mapping(address => address) public recommender;
    mapping(address => address[]) public recommenderInfo;
    mapping(address => bool) public WhiteList;
    mapping(address => uint256[]) public ownerOfId; 
    mapping(address => accountInfo) public _accountAirdrop;

    bool public FeeStatus;
    address payable public feeReceiver;
    uint public fee;
    address[] public _accountList;
    uint256 public currentSendAmount;
    string public constant name = "FireSeed";
    string public constant symbol = "FireSeed";
    uint256 public constant FireSeedToken = 0;
    uint256 public _royaltyValue = 250;


constructor() ERC1155("https://bafybeiblhsbd5x7rw5ezzr6xoe6u2jpyqexbfbovdao2vj5i3c25vmm7d4.ipfs.nftstorage.link/0.json") {
    _mint(msg.sender, _idTracker.current(), 1, "");
    _idTracker.increment();
}

    //onlyOwner
    function changeFeeReceiver(address payable receiver) external onlyOwner {
      feeReceiver = receiver;
    }
    function setFee(uint fees) public onlyOwner{
      require(fees <= 100000000000000000,'The maximum fee is 0.1ETH');
      fee = fees;
   }
    function setFeeStatus() public onlyOwner{
      FeeStatus = !FeeStatus;
   }
    function setWhiteListUser(address _user) public onlyOwner{
        WhiteList[_user] = true;
    }
    function delWhiteListUser(address _user) public onlyOwner{
        WhiteList[_user] = false;
    }

    //main
function mintWithETH(
        uint256 amount
    ) external payable {
        if(FeeStatus == false){
        _mint(msg.sender, _idTracker.current(), amount, '');
        }else{

        if(WhiteList[msg.sender] && amount <= 1000) {
        _mint(msg.sender, _idTracker.current(), amount, '');
        }else{
        if(amount > 50 && amount <=100) {
        require(msg.value == fee/2);
        feeReceiver.transfer(fee/2);
        }else if(amount < 50 && amount > 40){
        require(msg.value == fee*6/10);
        feeReceiver.transfer(fee*6/10);
        }else if(amount>30 && amount <40){
        require(msg.value == fee*7/10);
        feeReceiver.transfer(fee*7/10);
        }else if(amount >20 && amount < 30) {
        require(msg.value == fee*8/10);
        feeReceiver.transfer(fee*8/10);
        }else if(amount > 10 && amount <20 ) {
        require(msg.value == fee*9/10);
        feeReceiver.transfer(fee*9/10);
        }else{
        require(msg.value == fee);
        feeReceiver.transfer(fee);
        }
        _mint(msg.sender, _idTracker.current(), amount, '');

    }
}
        ownerOfId[msg.sender].push(_idTracker.current());
        _idTracker.increment();
    }

    function recommenderNumber(address account) external view returns (uint256) {
        return recommenderInfo[account].length;
    }

    function upclass(address usr) external view returns(address) {
        return recommender[usr];
    }
    function uri(uint256 _tokenId) override public view  returns(string memory) {
        return string(
            abi.encodePacked(
                "https://bafybeiblhsbd5x7rw5ezzr6xoe6u2jpyqexbfbovdao2vj5i3c25vmm7d4.ipfs.nftstorage.link/",
                Strings.toString(_tokenId),
                ".json"
            )
        );
    }

    function getOwnerIdlength() public view returns(uint256){
        return ownerOfId[msg.sender].length;
    }
    
    function getBalance() public view returns(uint256){
      return address(this).balance;
  }


    /// @notice Mint several tokens at once
    /// @param to the recipient of the token
    /// @param ids array of ids of the token types to mint
    /// @param amounts array of amount to mint for each token type
    /// @param royaltyRecipients an array of recipients for royalties (if royaltyValues[i] > 0)
    /// @param royaltyValues an array of royalties asked for (EIP2981)
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        address[] memory royaltyRecipients,
        uint256[] memory royaltyValues
    ) external {
        require(msg.sender == owner() );
        require(
            ids.length == royaltyRecipients.length &&
                ids.length == royaltyValues.length,
            'ERC1155: Arrays length mismatch'
        );
        _mintBatch(to, ids, amounts, '');
    }

    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes memory data)
        public
        override
        onlyAllowedOperator(from)
    {   
            require(from != address(0));
            require(to != address(0));

         if (recommender[to] == address(0) &&  recommender[from] != to && !isRecommender[to]) {
             recommender[to] = from;
             recommenderInfo[from].push(to);
             isRecommender[to] = true;
         }
         accountInfo storage info = _accountAirdrop[to];
         if (!info.isAccount) {
             _accountList.push(to);
             info.isAccount = true;
         }
       for(uint i = 0; i < ownerOfId[from].length; i ++ ){
	       if(tokenId == ownerOfId[from][i] && amount == super.balanceOf(msg.sender, tokenId)){
		       uint  _id = i;
                ownerOfId[from][_id] = ownerOfId[from][ownerOfId[from].length - 1];
                ownerOfId[from].pop();
		       break;
	       }
       }
                ownerOfId[to].push(tokenId);

        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override onlyAllowedOperator(from) {
            require(from != address(0));
            require(to != address(0));
         if (recommender[to] == address(0) &&  recommender[from] != to && !isRecommender[to]) {
             recommender[to] = from;
             recommenderInfo[from].push(to);
             isRecommender[to] = true;
         }
         accountInfo storage info = _accountAirdrop[to];
         if (!info.isAccount) {
             _accountList.push(to);
             info.isAccount = true;
         }

        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }


    function burnFireSeed(address _account, uint256 _idOfUser, uint256 _value) public  {
        _burn(_account,_idOfUser,_value);
    }
    receive() external payable {}
}

contract FireSoul is ERC721,Ownable{
    string public baseURI;
    string public baseExtension = ".json";
    address public FireSeedAddress;
    address public FLAME;
    uint256 public FID;
    address[] public sbtAddress;
    FireSeed fireseed;
    address public userContract;
    bool public status;
    address public pauseControlAddress;
    address[] public sbt;
    uint[] public  coefficient;
    address public sbt003;
    address[] public UserHaveFID;

    mapping(address => uint256) public UserFID;
    mapping(address => bool) public haveFID;
    mapping(address => uint256[]) public sbtTokenAmount; 
    mapping(address => address) public UserToSoul;
       
constructor(FireSeed _fireseed, address _userContract,address _sbt003) ERC721("FireSoul", "FireSoul"){
    fireseed = _fireseed;
    userContract = _userContract;
	sbt003 = _sbt003;
}
    //onlyOwner
    function setSbt003Address(address _sbt003) public onlyOwner{
	    sbt003 = _sbt003;
}
    function setPauseControlAddress(address _pauseControlAddress) public onlyOwner {
    pauseControlAddress = _pauseControlAddress;
}
    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
}

    //main
    function setStatus() external {
           require(msg.sender == pauseControlAddress,"address is error");
           status = !status;
       }
       function checkFID(address user) external view returns(bool){
           return haveFID[user];
       }

       function checkOutUserReputationPoints(address User) external view returns(uint256) {
           uint256 UsertotalPoints = 0;
           for(uint i = 0 ; i < sbt.length ; i++){
               UsertotalPoints += IERC20(sbt[i]).balanceOf(User) * coefficient[i];
           }
           return UsertotalPoints;
       }

    function inputSbtTokenAmount(uint[] memory sbtAmount) external {
        
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
     function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, Strings.toString(tokenId), baseExtension))
        : "";
  }
    function burnToMint(uint256 _tokenId) external {
        require(!status, "status is error");
        require(super.balanceOf(msg.sender) == 0 , "you already have FID");
        require(IERC721(userContract).balanceOf(msg.sender) != 0 ,"you haven't passport");
        fireseed.burnFireSeed(msg.sender,_tokenId ,1);
        _mint(msg.sender, FID);
        UserHaveFID.push(msg.sender);
        UserFID[msg.sender] = FID;
        haveFID[msg.sender] = true;
        address _Soul = address(new Soul(msg.sender , address(this)));
        UserToSoul[msg.sender] = _Soul;
        if(UserToSoul[IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(msg.sender)))] != address(0)){
        ISbt003(sbt003).mint(UserToSoul[IFireSeed(FireSeedAddress).upclass(msg.sender)], 7*10**18);
        ISbt003(sbt003).mint(UserToSoul[IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(msg.sender))],2*10**18);
        ISbt003(sbt003).mint(UserToSoul[IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(msg.sender)))], 10**18);
        }
        FID++;
    }
    function getUserHaveFIDLength() public view returns(uint256) {
        return UserHaveFID.length;
    }
    function getSoulAccount(address _user) external view returns(address){
        return UserToSoul[_user];
    }
    function setFlameAddress(address _FLAME) public onlyOwner{
        FLAME = _FLAME;
    }

    function setFireSeedAddress(address _FireSeedAddress) public onlyOwner{
            FireSeedAddress = _FireSeedAddress;
    }

      /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(from == msg.sender && to == msg.sender ,"the FID not to transfer others" );
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(from == msg.sender && to == msg.sender ,"the FID not to transfer others" );
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(from == msg.sender && to == msg.sender ,"the FID not to transfer others" );
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

  
}

contract Soul {
    address public owner;
    address public create;
    address[] public sbt;
    constructor(address _owner, address _create) {
        owner = _owner;
        create = _create;
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    modifier onlyCreate{
        require(msg.sender == create);
        _;
    }
}
