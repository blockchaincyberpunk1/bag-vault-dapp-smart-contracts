// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Provenance Tracking for Luxury Bags
 * @dev Manages and records the history of ownership and authenticity verification for luxury bag NFTs.
 * It allows for the appending of records upon transfer or verification updates and provides public view functions
 * to access a bag's provenance and authenticity information.
 */
contract ProvenanceTracking is Ownable {
    struct ProvenanceRecord {
        uint256 timestamp;
        string description;
    }

    // Mapping from token ID to list of ownership and authenticity verification records
    mapping(uint256 => ProvenanceRecord[]) private _provenanceRecords;

    // Event emitted when a new provenance record is added
    event ProvenanceRecordAdded(uint256 indexed tokenId, uint256 timestamp, string description);

    /**
     * @notice Adds a new provenance record for a luxury bag.
     * @dev Appends a new record to the token's provenance history.
     * @param tokenId The token ID of the luxury bag NFT.
     * @param description A description of the provenance event (e.g., "ownership transfer", "authenticity verification").
     */
    function addProvenanceRecord(uint256 tokenId, string memory description) public onlyOwner {
        _provenanceRecords[tokenId].push(ProvenanceRecord(block.timestamp, description));
        emit ProvenanceRecordAdded(tokenId, block.timestamp, description);
    }

    /**
     * @notice Retrieves the provenance records for a luxury bag.
     * @dev Returns all provenance records associated with the token ID.
     * @param tokenId The token ID of the luxury bag NFT.
     * @return records An array of provenance records for the specified token.
     */
    function getProvenanceRecords(uint256 tokenId) public view returns (ProvenanceRecord[] memory records) {
        return _provenanceRecords[tokenId];
    }
}
