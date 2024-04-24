// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Marketplace for Luxury Bag NFTs
 * @dev Facilitates the listing, buying, and selling of luxury bags represented as NFTs. 
 * Manages listings, executes sales, and handles NFT transfers, ensuring sellers receive payment.
 */
contract Marketplace is Ownable {
    struct Listing {
        address seller;
        address tokenAddress;
        uint256 tokenId;
        uint256 price;
        bool isActive;
    }

    // ERC20 token used for transactions
    IERC20 public paymentToken;

    // Array of listings
    Listing[] public listings;

    // Event emitted when a new listing is created
    event ListingCreated(uint256 indexed listingId, address indexed seller, address tokenAddress, uint256 tokenId, uint256 price);

    // Event emitted when a listing is successfully sold
    event SaleCompleted(uint256 indexed listingId, address indexed buyer, uint256 price);

    // Event emitted when a listing is cancelled
    event ListingCancelled(uint256 indexed listingId);

    /**
     * @dev Sets the ERC20 token used for transactions.
     * @param _paymentToken Address of the ERC20 token.
     */
    constructor(address _paymentToken) {
        require(_paymentToken != address(0), "Invalid payment token address");
        paymentToken = IERC20(_paymentToken);
    }

    /**
     * @notice Creates a new listing for a luxury bag NFT.
     * @dev Lists an NFT on the marketplace, allowing others to purchase it.
     * @param tokenAddress The address of the NFT contract.
     * @param tokenId The ID of the NFT to list.
     * @param price The price for the listed NFT.
     * @return listingId The ID of the created listing.
     */
    function createListing(address tokenAddress, uint256 tokenId, uint256 price) external returns (uint256 listingId) {
        require(price > 0, "Price must be greater than zero");
        require(IERC721(tokenAddress).ownerOf(tokenId) == msg.sender, "Caller is not the owner of the NFT");

        IERC721(tokenAddress).transferFrom(msg.sender, address(this), tokenId);

        listingId = listings.length;
        listings.push(Listing({
            seller: msg.sender,
            tokenAddress: tokenAddress,
            tokenId: tokenId,
            price: price,
            isActive: true
        }));

        emit ListingCreated(listingId, msg.sender, tokenAddress, tokenId, price);
    }

    /**
     * @notice Buys a luxury bag NFT listed on the marketplace.
     * @dev Transfers the NFT to the buyer and the sale price to the seller.
     * @param listingId The ID of the listing to purchase.
     */
    function buyListing(uint256 listingId) external {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "Listing is not active");

        listing.isActive = false;
        paymentToken.transferFrom(msg.sender, listing.seller, listing.price);
        IERC721(listing.tokenAddress).transferFrom(address(this), msg.sender, listing.tokenId);

        emit SaleCompleted(listingId, msg.sender, listing.price);
    }

    /**
     * @notice Cancels an active listing.
     * @dev Can only be called by the listing's seller or the contract owner.
     * @param listingId The ID of the listing to cancel.
     */
    function cancelListing(uint256 listingId) external {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "Listing is not active");
        require(msg.sender == listing.seller || msg.sender == owner(), "Caller is not the seller or owner");

        listing.isActive = false;
        IERC721(listing.tokenAddress).transferFrom(address(this), listing.seller, listing.tokenId);

        emit ListingCancelled(listingId);
    }
}
