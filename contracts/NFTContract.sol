// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

//internal import for NFT oppenzeppelin 

import "@openzeppelin/contracts/utils/Counters.sol";            // for keep the track of token either created,sold.
import "@openzeppelin/contracts/token/ERC721URIStorage.sol";    // URL for NFT when user will make the nft to get data about it.
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

    // standard from Oppenzappelin //to trigger buying and selling events

    event idMarketItemCreated 
    (
        uint256 indexed tokenId,                   
        address seller,
        address owner,
        uint256 price,
        bool sold
    
    ) ; 

    modifier onlyOwner() 
    {require( msg.sender == owner );                //only owner of marketplace can change the listing price  
     _;                                             //after the condition gets True the function will continue
    } 

    constructor() ERC721("Mello", "MLO"){           //symbol and name of NFT
        owner == payable(msg.sender);
    }

   //only owner of this whole Marketplace would decide the NFT's price

    function updateListingPrice(uint256 _listingPrice) public payable onlyowner{ 
        listingPrice = _listingPrice;
    }
    function getListingPrice() public view returns (uint256) {    //for users to find current price of NFT
        return listingPrice;
    }

    // NFT TOKEN FUNCTIONS 
    //tokenURI is URL of token

    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256){
        _tokenIds.increment();          //when token mint the tokenId will increase.

        uint256 newTokenId = _tokenIds.current(); //after increment token Id is tokenIds.current() and it will asign to newTokenId

        _mint(msg.sender,newTokenId);           //from ERC721 

        _setTokenURI( newTokenId,tokenURI);     //from ERC721URIStorage
          
        createMarketItem(newTokenId,price);     //created for this contract
        
        return newTokenId;
    }

    // this function will create NFT and assign the creatMarketItem above data to that NFT
   
    createMarketItem(uint256 tokenId,uint256 price) private {     //not imported from any contract
         require(price > 0 ,"price must be at least 1");
         require(msg.value == listingPrice,"price must be equal to listing Price");

    //idMarketItem is mapping which contains all created NFT data  
    // we are giving the NFT details to mapping.

        idMarketItem[tokenId] = MarketItem(                         // this function contain all NFT's details 
        tokenId,
        payable (msg.sender),
        payable(address(this)),    // it means address of this smart contract
        price,
        false           //currnetly NFT is not sold so this is to  be false
    );
        _transfer(msg.sender,address(this),tokenId);  // sending this details to contract from owner
    }      

    // after the NFT's will mint this data will show.
    //fill data in similar order which is filled in event
    emit idMarketItemCreated(
        tokenId,
        msg.sender,
        address(this),
        price,
        false
    ):
    //for reselling of token
    function reSellToken(uint256 tokenId, uint256 price)public payable{  //function for user who can  resale token
        require (idMarketItem[tokenId].owner ==  msg.sender,"only NFT owner can Perform this function");
        require (msg.value == listingPrice, "Price must be Equal");
        
        idMarketItem[tokenId].sold = false;
        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].seller = payable (msg.sender);
        idMarketItem[tokenId].owner = payable (address(this));

        _itemSold.decrement();         // after reselling itemSold would be decrease by 1

        _transfer(msg.sender,address(this),tokenId);    //transfer this details to contract.
    }
    //function for Create market sale
 
    function CreateMarketSale(uint256 tokenId) public payable {
        uint256 price = idMarketItem[tokenId].price;

        require (msg.value== price, " Please submit the asking price in order to complete the purchase");

    idMarketItem[tokenId].owner = payable (msg.sender);
    idMarketItem[tokenId].sold = true;
    idMarketItem[tokenId].owner = payable (address(0));
    idMarketItem[tokenId].owner = payable (msg.sender);

    _itemSold.increment();

    _transfer(address(this),msg.sender,tokenId);

    payable(owner).transfer(listingPrice);                       // commission for contract owner once NFT sold.
    payable(idMarketItem[tokenId].seller).transfer(msg.value);

    }
    //Getting Unsold NFT data 

    function fetchMarketItem()public view returns(MarketItem[] memory){
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current() - _itemSold.current();
        uint256 currentIndex = 0;

        MarketItem[]memory items = new MarketItem[](unSoldItemCount)
        for (uint256 i=0; i< itemCount; i ++){
            if(idMarketItem)[i+1].owner == address((this)) {
                uint256 currentId = i + 1;

                MarketItem storage currentItem = idMarketItem [currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
     
    //purchase Item
    function fetchMyNFT() public view returns(MarketItem[] memory){
        uint256 totalCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0 ; i< totalCount; i++){
            if (IdMarketItem)[i + 1].owner == msg.sender{
                itemCount +=1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i< totalCount; i ++){
            if (idMarketItem[i+1].owner == msg.sender){
            uint256 currentId = i + 1;
            MarketItem storage currentItem = idMarketItem[currentId];
            items[current.Index] = currentItem;
            currentIndex +=1; } 
        }      
    
      return items;      
    }
        //Single User item

        function fetchItemsListed() public view returns(MarketItem[] memory){
            uint256 totalCount = _tokenIds.current();
            uint256 itemCount = 0;
            uint256 currentIndex = 0;

            for (uint256 i=0; i<totalCount; i++){
                if (idMarketItem[i+1].seller==msg.sender){
                    itemCount += 1;}
            }

            MarketItem[]memory items = new MarketItems[](itemCount);
            for (uint256 i = 0; i < totalCount; i ++){
                if (idMarketItem[i + 1 ].seller == msg.sender){
                   
                    uint256 currentId = i + 1;
                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentIndex] = currentItems;
                    currentIndex += 1; }
            }

            return items;
        }
}


 
