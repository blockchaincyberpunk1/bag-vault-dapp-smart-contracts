// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Access Control for Bag Vault dApp
 * @dev Manages roles and permissions for different operations within the dApp.
 * Utilizes OpenZeppelin's AccessControl for role-based permission management.
 */
contract BagVaultAccessControl is AccessControl {
    /// @dev Role definitions
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PROVENANCE_TRACKER_ROLE = keccak256("PROVENANCE_TRACKER_ROLE");

    /**
     * @dev Sets up the default admin role and grants the deployer admin permissions.
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(PROVENANCE_TRACKER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    /**
     * @notice Grants minter role to an account
     * @dev Grants `account` the MINTER_ROLE, allowing them to mint NFTs.
     * @param account The account to grant the minter role.
     */
    function grantMinterRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, account);
    }

    /**
     * @notice Grants provenance tracker role to an account
     * @dev Grants `account` the PROVENANCE_TRACKER_ROLE, allowing them to add provenance records.
     * @param account The account to grant the provenance tracker role.
     */
    function grantProvenanceTrackerRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(PROVENANCE_TRACKER_ROLE, account);
    }

    /**
     * @notice Revokes minter role from an account
     * @dev Revokes `account`'s MINTER_ROLE, removing their ability to mint NFTs.
     * @param account The account to revoke the minter role from.
     */
    function revokeMinterRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, account);
    }

    /**
     * @notice Revokes provenance tracker role from an account
     * @dev Revokes `account`'s PROVENANCE_TRACKER_ROLE, removing their ability to add provenance records.
     * @param account The account to revoke the provenance tracker role from.
     */
    function revokeProvenanceTrackerRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(PROVENANCE_TRACKER_ROLE, account);
    }
}
