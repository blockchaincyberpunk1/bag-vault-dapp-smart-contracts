// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Loyalty and Rewards Program Contract
 * @dev Implements a token-based rewards system for customers, managing the issuance of rewards for purchases, referrals, and incentivized activities, allowing token redemption for various benefits.
 */
contract LoyaltyRewards is Ownable, ReentrancyGuard {
    IERC20 public rewardsToken;

    mapping(address => uint256) public rewardsBalance;

    event RewardIssued(address indexed user, uint256 amount);
    event RewardRedeemed(address indexed user, uint256 amount);

    /**
     * @dev Sets the rewards token used in the loyalty program.
     * @param _rewardsTokenAddress Address of the ERC20 token to be used as rewards.
     */
    constructor(address _rewardsTokenAddress) {
        require(_rewardsTokenAddress != address(0), "Rewards token address cannot be the zero address");
        rewardsToken = IERC20(_rewardsTokenAddress);
    }

    /**
     * @dev Issues rewards to a user. Can only be called by the owner (dApp backend).
     * @param user The address of the user to issue rewards to.
     * @param amount The amount of rewards to issue.
     */
    function issueReward(address user, uint256 amount) external onlyOwner {
        require(user != address(0), "Cannot issue rewards to the zero address");
        require(amount > 0, "Amount must be greater than 0");

        rewardsBalance[user] += amount;
        emit RewardIssued(user, amount);
    }

    /**
     * @dev Allows users to redeem their rewards for benefits.
     * @param amount The amount of rewards to redeem.
     */
    function redeemRewards(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(rewardsBalance[msg.sender] >= amount, "Insufficient rewards balance");

        rewardsBalance[msg.sender] -= amount;
        require(rewardsToken.transfer(msg.sender, amount), "Failed to transfer rewards");

        emit RewardRedeemed(msg.sender, amount);
    }

    // Additional functionalities like updating the rewards token, adjusting reward rates, or adding new types of rewards could be implemented here.
}
