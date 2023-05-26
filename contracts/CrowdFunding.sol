// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdFunding {
    IERC20 public token;

    event campaignCreated(uint id, address indexed creator, uint _days);
    event donated(uint indexed id, address indexed donator, uint amount);
    event claimed(uint id, uint amount);
    event refunded(address indexed donator, uint indexed id);

    struct Campaign {
        address creator;
        uint256 goal;
        uint256 raised;
        uint256 campaignTime;
        bool isClaimed;
    }

    uint public count;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public amountDonated;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function startCampaign(uint _goal, uint _days) external {
        require(_days > 0, "Campaign should atleast run for 1 day");
        require(_days <= 30, "Campaign cannot run for more than 30 days");
        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            raised: 0,
            campaignTime: block.timestamp + (_days * 1 days),
            isClaimed: false
        });

        emit campaignCreated(count, msg.sender, _days);
    }

    function donateCampaign(uint _id, uint amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.campaignTime, "Campaign has ended");

        campaign.raised += amount;
        amountDonated[_id][msg.sender] += amount;

        token.transferFrom(msg.sender, address(this), amount);

        emit donated(_id, msg.sender, amount);
    }

    function claimFunds(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(
            campaign.campaignTime <= block.timestamp,
            "Campaign isnt ended yet"
        );
        require(
            msg.sender == campaign.creator,
            "only creator is allowed to withdraw the fund"
        );
        require(
            campaign.raised >= campaign.goal,
            "campaign has not reached the goal"
        );
        require(!campaign.isClaimed, "You have already claimed the amount");

        campaign.isClaimed = true;
        token.transfer(msg.sender, campaign.raised);

        emit claimed(_id, campaign.raised);
    }

    function refundDonation(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(
            campaign.campaignTime <= block.timestamp,
            "campaign isnt ended yet"
        );
        require(
            campaign.raised < campaign.goal,
            "Campaign has reached the goal"
        );

        uint balance = amountDonated[_id][msg.sender];
        amountDonated[_id][msg.sender] = 0;
        token.transfer(msg.sender, balance);

        emit refunded(msg.sender, _id);
    }
}
