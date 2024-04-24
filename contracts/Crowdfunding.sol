// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Crowdfunding Platform for Emerging Luxury Bag Designers
 * @dev Enables emerging designers to raise funds for new luxury bag designs, tracking contributions and disbursing funds upon successful campaign completions. Optionally issues equity tokens to contributors.
 */
contract Crowdfunding is AccessControl, ReentrancyGuard {
    bytes32 public constant DESIGNER_ROLE = keccak256("DESIGNER_ROLE");
    IERC20 private paymentToken;

    struct Campaign {
        address creator;
        uint256 goalAmount;
        uint256 currentAmount;
        uint256 endTime;
        bool isFunded;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public nextCampaignId;

    event CampaignCreated(uint256 indexed campaignId, address creator, uint256 goalAmount, uint256 endTime);
    event ContributionMade(uint256 indexed campaignId, address contributor, uint256 amount);
    event CampaignFunded(uint256 indexed campaignId);
    event FundsClaimed(uint256 indexed campaignId, uint256 amount);

    constructor(address _paymentTokenAddress) {
        require(_paymentTokenAddress != address(0), "Invalid token address");
        paymentToken = IERC20(_paymentTokenAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Creates a new crowdfunding campaign.
     * @param goalAmount The amount of tokens to be raised.
     * @param endTime The end time of the campaign.
     */
    function createCampaign(uint256 goalAmount, uint256 endTime) external onlyRole(DESIGNER_ROLE) {
        require(goalAmount > 0, "Goal amount must be greater than 0");
        require(endTime > block.timestamp, "End time must be in the future");

        campaigns[nextCampaignId] = Campaign({
            creator: msg.sender,
            goalAmount: goalAmount,
            currentAmount: 0,
            endTime: endTime,
            isFunded: false
        });

        emit CampaignCreated(nextCampaignId, msg.sender, goalAmount, endTime);
        nextCampaignId++;
    }

    /**
     * @notice Allows contributors to contribute to a campaign.
     * @param campaignId The ID of the campaign to contribute to.
     * @param amount The amount of tokens to contribute.
     */
    function contribute(uint256 campaignId, uint256 amount) external nonReentrant {
        Campaign storage campaign = campaigns[campaignId];
        require(block.timestamp < campaign.endTime, "Campaign has ended");
        require(amount > 0, "Contribution amount must be greater than 0");
        require(paymentToken.transferFrom(msg.sender, address(this), amount), "Failed to transfer tokens");

        campaign.currentAmount += amount;
        emit ContributionMade(campaignId, msg.sender, amount);

        if (campaign.currentAmount >= campaign.goalAmount) {
            campaign.isFunded = true;
            emit CampaignFunded(campaignId);
        }
    }

    /**
     * @notice Allows the campaign creator to claim the funds after the campaign is successfully funded.
     * @param campaignId The ID of the campaign to claim funds for.
     */
    function claimFunds(uint256 campaignId) external {
        Campaign storage campaign = campaigns[campaignId];
        require(msg.sender == campaign.creator, "Only the campaign creator can claim funds");
        require(campaign.isFunded, "Campaign is not funded");
        require(campaign.currentAmount > 0, "No funds to claim");

        uint256 amount = campaign.currentAmount;
        campaign.currentAmount = 0; // Prevent re-entrancy
        require(paymentToken.transfer(campaign.creator, amount), "Failed to transfer funds");

        emit FundsClaimed(campaignId, amount);
    }

    // Additional functions to handle campaign modifications, cancellation, and equity token issuance could be added here.
}
