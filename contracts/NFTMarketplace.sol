// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./Authentication.sol"; // Assuming this is the path to the Authentication contract

/**
 * @title NFT Marketplace for Digital and Physical Luxury Bags
 * @dev Supports exclusive NFTs representing both digital and physical luxury bags with auction-based or fixed-price sales.
 * Integrates with the Authentication contract for verifying the authenticity of bags represented by NFTs.
 */
contract NFTMarketplace is Ownable, ReentrancyGuard {
    // Assuming the Authentication contract has been deployed and its address is known
    Authentication private authenticationContract;

    struct Sale {
        address seller;
        uint256 price;
        bool isAuction;
        uint256 auctionEndTime;
        bool isActive;
    }

    mapping(uint256 => Sale) public sales;

    event SaleCreated(uint256 indexed tokenId, uint256 price, bool isAuction, uint256 auctionEndTime);
    event SaleConcluded(uint256 indexed tokenId, address buyer, uint256 finalPrice);
    event SaleCancelled(uint256 indexed tokenId);

    /**
     * @dev Sets the address for the Authentication contract used to verify NFT authenticity.
     * @param _authContract Address of the Authentication contract.
     */
    constructor(address _authContract) {
        require(_authContract != address(0), "Authentication contract address cannot be the zero address.");
        authenticationContract = Authentication(_authContract);
    }

    /**
     * @notice Creates a sale for a luxury bag NFT, either as a fixed-price sale or an auction.
     * @dev Sellers can choose to list their NFTs in an auction or for a fixed price.
     * @param tokenId The ID of the NFT to be sold.
     * @param price The price (or starting price, if an auction) in wei.
     * @param isAuction Boolean indicating if the sale is an auction.
     * @param auctionEndTime The end time for the auction (if applicable).
     */
    function createSale(uint256 tokenId, uint256 price, bool isAuction, uint256 auctionEndTime) external onlyOwner {
        require(authenticationContract.isAuthentic(tokenId), "NFT is not authenticated.");
        require(price > 0, "Price must be greater than zero.");
        if(isAuction) {
            require(auctionEndTime > block.timestamp, "Auction end time must be in the future.");
        }

        sales[tokenId] = Sale({
            seller: msg.sender,
            price: price,
            isAuction: isAuction,
            auctionEndTime: auctionEndTime,
            isActive: true
        });

        emit SaleCreated(tokenId, price, isAuction, auctionEndTime);
    }

    /**
     * @notice Allows buyers to purchase or place a bid on a listed NFT.
     * @dev Handles both auction bids and fixed-price sales. For auctions, the highest bid at the auction end time wins.
     * @param tokenId The ID of the NFT being purchased or bid on.
     * @param offer The amount of the offer or bid in wei.
     */
    function buyOrBid(uint256 tokenId, uint256 offer) external nonReentrant {
        Sale storage sale = sales[tokenId];
        require(sale.isActive, "Sale is not active.");
        require(offer >= sale.price, "Offer is less than the sale price.");

        if(sale.isAuction) {
            require(block.timestamp < sale.auctionEndTime, "Auction has ended.");
            // Assuming there's an auction bid handling mechanism here
        } else {
            // Direct purchase for fixed-price sales
            sale.isActive = false;
            // Transfer funds and ownership here
            emit SaleConcluded(tokenId, msg.sender, offer);
        }
    }

    /**
     * @notice Cancels an active sale or auction for a luxury bag NFT.
     * @dev Can only be called by the seller or the contract owner. The NFT is returned to the seller.
     * @param tokenId The ID of the NFT whose sale is to be cancelled.
     */
    function cancelSale(uint256 tokenId) external {
        Sale storage sale = sales[tokenId];
        require(sale.seller == msg.sender || msg.sender == owner(), "Caller is not the seller or owner.");
        sale.isActive = false;

        emit SaleCancelled(tokenId);
    }

    // Additional functions for auction handling, transferring NFTs, and managing funds could be added here.
}
