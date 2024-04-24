// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Authentication Contract for Luxury Bags
 * @dev This contract manages the minting of NFTs representing luxury bags, serving as a digital certificate of authenticity.
 * It allows the dApp owner or other authorized entities to create new tokens upon verification of authenticity.
 */
contract Authentication is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    /**
     * @dev Emitted when a new luxury bag NFT is minted and its authenticity is registered.
     * @param tokenId The unique identifier for the minted NFT.
     * @param owner The owner of the newly minted NFT.
     */
    event AuthenticityRegistered(uint256 indexed tokenId, address indexed owner);

    /**
     * @dev Constructs the Authentication contract.
     * @param name Name of the NFT collection.
     * @param symbol Symbol of the NFT collection.
     */
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    /**
     * @notice Mints a new luxury bag NFT representing a digital certificate of authenticity.
     * @dev Mints a new NFT to the specified owner with the given token URI.
     * @param owner The owner of the newly minted NFT.
     * @param tokenURI The URI pointing to the metadata of the minted NFT.
     * @return tokenId The unique identifier for the minted NFT.
     */
    function registerAuthenticity(address owner, string memory tokenURI) public onlyOwner returns (uint256 tokenId) {
        _tokenIdCounter++;
        tokenId = _tokenIdCounter;

        _mint(owner, tokenId);
        _setTokenURI(tokenId, tokenURI);

        emit AuthenticityRegistered(tokenId, owner);
    }

    /**
     * @notice Retrieves the total number of minted NFTs.
     * @dev Returns the total count of NFTs minted by the contract.
     * @return The total count of minted NFTs.
     */
    function totalMinted() public view returns (uint256) {
        return _tokenIdCounter;
    }
}
