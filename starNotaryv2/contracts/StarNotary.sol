pragma solidity ^0.8.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {

    struct Star {
        string name;
        uint256 id;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(string => Star) public tokenName_StarInfo;
    mapping(uint256 => uint256) public starsForSale;

    constructor() ERC721('StarMate', 'STM') {
    }
 
    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public {
        Star memory newStar = Star(_name, _tokenId);
        tokenIdToStarInfo[_tokenId] = newStar;
        tokenName_StarInfo[_name] = newStar;
        _mint(msg.sender, _tokenId);
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }
 
    function _make_payable(address x) internal pure returns (address payable) {
        return payable(address(uint160(x)));
    }

    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        transferFrom(ownerAddress, msg.sender, _tokenId);
        address payable ownerAddressPayable = _make_payable(ownerAddress);
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
           payable(msg.sender).transfer(msg.value - starCost);
        }
    }        
  
    function approveTransaction(address buyer, uint256 tokenId)
        internal {
            this.approve(buyer, tokenId);
    }


}