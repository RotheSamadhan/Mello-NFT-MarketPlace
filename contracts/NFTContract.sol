// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

//internal import for NFT oppenzeppelin 
import "@openzeppelin/contracts/utils/Counters.sol";         // for keep the track of token either created,sold.
import "@openzeppelin/contracts/token/ERC721URIStorage.sol"; // URL for NFT when user will make the nft to get data about it.
import "@openzeppelin/contracts/token/ERC721.sol";
 
import "hardhat/console.sol";
 
contract NFTContract is ERC721URIStorage {  
  using Counters for Counters.Counter;                        //from Counters.sol

    Counters.Counter private _tokenIds;                       //track of token ID
    Counters.Counter private _itemSold;                        // track of sold tokens

    uint256 listingPrice = 0.0015 ether;

    address payable owner; 

    mapping (uint256 => MarketItem) private idMarketItem;

    struct MarketItem                                         //  NFT details and track
    {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // standard from Oppenzappelin //to trigger buying and selling evens

    event idMarketItemCreated 
    (
        uint256 indexed tokenId,                   
        address seller,
        address owner,
        uint256 price,
        bool sold
    
    ) ; 

    modifier onlyOwner() 
    {require(
        msg.sender ==owner;                               //only owner of marketplace can change the listing price  
    );
        _;                                                //after the modifer owner gets True the function will continue
    }

    constructor() ERC721("NFT Mello Token", "Mello"){     //symbol and name for NFT
        owner == payable(msg.sender);
    }

   //only owner of this whole Marketplace would decide the NFT's price

    function updateListingPrice(uint256 _listingPrice) public payable onlyowner{ 
        listingPrice = _listingPrice;
    }
    function getListingPrice() public view returns (uint256) {  //for users to find current price of NFT
        return listingPrice;
    }

    // NFT TOKEN FUNCTIONS 

    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256){
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender,newTokenId);

        _setTokenURI( newTokenId,tokenURI);
          
        return newTokenId;
    }
    createMarketItem(uint256 tokenId,uint256 price) private {
         require(price >0 ,"price must be at least 1");
         require(msg.value == listingPrice,"price must be equal to listing Price");

         idMarketItem[tokenId] = MarketItem (                         // this function contain all NFT's details 
            tokenId,
            payable (msg.sender),
            payable(address(this)),
            price,
            false,
         );
         _transfer(msg.sender,address(this),tokenId);                  // sending this details to contract
    }      

} 