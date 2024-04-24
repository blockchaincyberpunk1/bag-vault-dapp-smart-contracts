// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title UUPS Upgradeable Proxy Contract
 * @dev Implements upgradeability using the UUPS design pattern.
 */
contract MyUpgradeableContract is UUPSUpgradeable, Ownable {
    string public value;

    /**
     * @dev Initializes the contract with initial values.
     * @param initialValue A value to set at deployment.
     */
    function initialize(string memory initialValue) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init();
        value = initialValue;
    }

    /**
     * @dev Example function to demonstrate upgradeability.
     * @param newValue The new value to store in the contract.
     */
    function setValue(string memory newValue) public {
        value = newValue;
    }

    /**
     * @dev Authorization function for contract upgrades. Restricts upgrade capability to the contract owner.
     * @param newImplementation The address of the new contract implementation.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // Additional functions to demonstrate functionality can be added here
}
