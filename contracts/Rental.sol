// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Rental Contract for Luxury Bag NFTs
 * @dev Enables NFT owners to list their luxury bags for rent, manages rental agreements, durations, and payments.
 * Ensures the secure transfer of NFTs between the lender and renter for the rental period.
 */
contract Rental is Ownable, ReentrancyGuard {
    struct RentalAgreement {
        address lender;
        address renter;
        uint256 tokenId;
        uint256 pricePerDay;
        uint256 rentalDuration;
        uint256 startTime;
        bool isActive;
    }

    IERC721 public nftContract;
    mapping(uint256 => RentalAgreement) public agreements;

    event RentalListed(uint256 tokenId, address lender, uint256 pricePerDay, uint256 rentalDuration);
    event RentalAgreementCreated(uint256 tokenId, address renter, uint256 startTime, uint256 rentalDuration);
    event RentalAgreementEnded(uint256 tokenId, address renter);

    /**
     * @dev Initializes the contract by setting the NFT contract address.
     * @param _nftContract Address of the NFT contract.
     */
    constructor(address _nftContract) {
        require(_nftContract != address(0), "Invalid NFT contract address");
        nftContract = IERC721(_nftContract);
    }

    /**
     * @notice Allows NFT owners to list their luxury bags for rent.
     * @param tokenId The ID of the NFT (luxury bag) to list for rent.
     * @param pricePerDay The daily rental price in wei.
     * @param rentalDuration The maximum rental duration in days.
     */
    function listForRent(uint256 tokenId, uint256 pricePerDay, uint256 rentalDuration) external onlyOwner {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Caller is not the NFT owner");
        require(pricePerDay > 0, "Price per day must be greater than zero");
        require(rentalDuration > 0, "Rental duration must be greater than zero");

        agreements[tokenId] = RentalAgreement({
            lender: msg.sender,
            renter: address(0),
            tokenId: tokenId,
            pricePerDay: pricePerDay,
            rentalDuration: rentalDuration,
            startTime: 0,
            isActive: true
        });

        emit RentalListed(tokenId, msg.sender, pricePerDay, rentalDuration);
    }

    /**
     * @notice Allows users to rent a listed luxury bag NFT for a specified duration.
     * @dev Transfers the NFT to the renter for the duration of the rental period.
     * @param tokenId The ID of the NFT to rent.
     * @param rentalDuration The duration of the rental in days.
     */
    function rent(uint256 tokenId, uint256 rentalDuration) external payable nonReentrant {
        RentalAgreement storage agreement = agreements[tokenId];
        require(agreement.isActive, "Rental agreement is not active");
        require(rentalDuration <= agreement.rentalDuration, "Rental duration exceeds maximum allowed");
        require(msg.value == agreement.pricePerDay * rentalDuration, "Incorrect rental price");

        agreement.renter = msg.sender;
        agreement.startTime = block.timestamp;
        nftContract.transferFrom(agreement.lender, msg.sender, tokenId);

        emit RentalAgreementCreated(tokenId, msg.sender, block.timestamp, rentalDuration);
    }

    /**
     * @notice Ends the rental agreement and returns the NFT to the lender.
     * @dev Can be called by the lender or renter after the rental period has ended.
     * @param tokenId The ID of the rented NFT.
     */
    function endRental(uint256 tokenId) external {
        RentalAgreement storage agreement = agreements[tokenId];
        require(agreement.isActive, "Rental agreement is not active");
        require(agreement.renter == msg.sender || agreement.lender == msg.sender, "Caller is neither renter nor lender");
        require(block.timestamp >= agreement.startTime + agreement.rentalDuration * 1 days, "Rental period has not ended");

        agreement.isActive = false;
        nftContract.transferFrom(msg.sender, agreement.lender, tokenId);

        emit RentalAgreementEnded(tokenId, msg.sender);
    }
}
