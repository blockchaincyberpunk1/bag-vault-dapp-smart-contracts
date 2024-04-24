// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BagVaultToken
 * @dev This contract extends an ERC20 token with functionalities for minting, burning, and ownership management. 
 * It is used within the Bag Vault dApp for transactions, rewards, and crowdfunding.
 */
contract BagVaultToken is ERC20, ERC20Burnable, Ownable {
    /**
     * @dev Initializes the contract with a name and a symbol for the token.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    /**
     * @notice Mint new tokens.
     * @dev Creates `amount` tokens and assigns them to `account`, increasing the total supply.
     * @param account The account to receive the created tokens.
     * @param amount The amount of tokens to create.
     * Requirements:
     * - the caller must have the `DEFAULT_ADMIN_ROLE`.
     */
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    /**
     * @notice Burn tokens from the owner account.
     * @dev Destroys `amount` tokens from the caller, reducing the total supply.
     * @param amount The amount of tokens to burn.
     * Overrides ERC20Burnable's `burn` to be publicly accessible.
     */
    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    /**
     * @notice Burn tokens from a specified account.
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's allowance.
     * @param account The account to burn tokens from.
     * @param amount The amount of tokens to burn.
     * Requirements:
     * - the caller must have allowance for `account`'s tokens of at least `amount`.
     * Overrides ERC20Burnable's `burnFrom` to be publicly accessible.
     */
    function burnFrom(address account, uint256 amount) public override {
        super.burnFrom(account, amount);
    }
}
