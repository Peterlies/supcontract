// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";




contract FireSeed is ERC1155PresetMinterPauser ,ReentrancyGuard {

    mapping(address => bool) public isRecommender;
    mapping(address => address) public recommender;
    mapping(address => address[]) public recommenderInfo;

    struct accountInfo {
        bool isAccount;
        uint256 settleTime;
        uint256 incomeTime;
        uint256 incomeAmount;
        uint256 cacheAmount;
    }
    mapping(address => accountInfo) public _accountAirdrop;
    address[] public _accountList;



    uint8 tokenId = 1;
    uint256 public currentSendAmount;


    constructor() ERC1155PresetMinterPauser("test"){

    }

    function recommenderNumber(address account) external view returns (uint256) {
        return recommenderInfo[account].length;
    }

    function upclass(address usr) public view returns(address) {
        return recommender[usr];
    }

 
    // function transferToken(
    //         address from,
    //         address to
    
    //     ) public {
        //      require(from != address(0));
        //      require(to != address(0));

        //  if (recommender[to] == address(0) &&  recommender[from] != to && !isRecommender[to]) {
        //      recommender[to] = from;
        //      recommenderInfo[from].push(to);
        //      isRecommender[to] = true;
        //  }
        //  accountInfo storage info = _accountAirdrop[to];
        //  if (!info.isAccount) {
        //      _accountList.push(to);
        //      info.isAccount = true;
        //  }


    //     safeTransferFrom(from, to, tokenId, tokenId ,"test");
    //     currentSendAmount++;
    // }
   function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
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
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
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

        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }



    // function burnFireSeed(address _account, uint256 _id, uint256 _value) public  {
    //     burn(_account,_id,_value);
    // }


}


   contract FireSoul is ERC721,ReentrancyGuard{

        // bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

        uint256 public FID;
        address[] public sbtAddress;
        FireSeed fireseed;
       address public _owner;
       constructor(FireSeed _fireseed) ERC721("FireSoul", "FireSoul"){

        _owner = msg.sender;
        fireseed = _fireseed;

       }
        function burnToMint() external {
        require(fireseed.balanceOf(msg.sender,1) != 0 );
        fireseed.burn(msg.sender, 1,1);
        _mint(msg.sender, FID);
        FID++;
    }

    function setSBTAddress(address sbt) public {
        for(uint256 i = 0; i < sbtAddress.length; i++){
            sbtAddress[i] = sbt;
        }
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

    // function safeTransferFrom(address from, address to, uint256 tokenId) public override {

    //     require(from == msg.sender && to == msg.sender ,"the FID not to transfer others" );
    //     _transfer(from, to, tokenId);

    // }
}