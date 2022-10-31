// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.15;

import "./SponsorFunding.sol";
import "./DistributeFunding.sol";

  /**
   * @title CrowdFunding
   * @dev ContractDescription
   * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
   */
contract CrowdFunding {
    uint fundingGoal;
    bool fundingGoalReached = false;
    uint amountRaised = 0;

    SponsorFunding sponsorFunding;
    DistributeFunding distributeFunding;
    mapping(address => Contributor) contributors;    

    // events
    event fallbackCall(string);
    event receivedFunds(address, uint);

    struct Contributor {
        // address contributorAddress;
        uint amount;
        string name;
        // can add more later
    }

    constructor() {
        fundingGoal = 10000;
    }

    function getFundingGoal() public view returns(uint) {
        return fundingGoal;
    }

    // pledge sum
    function pledge(string calldata _name) payable external {
        require(!fundingGoalReached, "Funding goal has been reached");

        amountRaised += msg.value;
        contributors[msg.sender].name = _name;
        contributors[msg.sender].amount = msg.value;
        
        payable(address(this)).transfer(msg.value);

        if(amountRaised >= fundingGoal) {
            fundingGoalReached = true;

            // can automatically call the sponsor method here or manually call it later
            // will make a function to manually call it for now
        }
    }

    // retract sum
    function retract(uint _amount) payable external {
        require(contributors[msg.sender].amount >= _amount, "Cannot retract more than you pledged");
        require(!fundingGoalReached, "Cannot retract once the goal has been reached");

        contributors[msg.sender].amount -= _amount;
        amountRaised -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    // check if goal has been reached 
    function checkGoalReached() public view returns(bool) {
        return fundingGoalReached;
    }

    // get amount raised until now
    function getAmountRaised() public view returns(uint) {
        return address(this).balance;
    }

    function setSponsor(SponsorFunding _sponsorFunding) public {
        sponsorFunding = _sponsorFunding;
    }
    
    // contact sponsor
    function getSponsorFunding() payable public {
        require(fundingGoalReached, "Target has not been reached yet");

        sponsorFunding.donate(amountRaised);
    }

    function setDistributeFunding(DistributeFunding _distributeFunding) public {
        distributeFunding = _distributeFunding;
    }

    // distribute funding
    function sendToDistributeFunding() payable public {
        require(fundingGoalReached, "Target has not been reached yet");

        amountRaised = 0;
        payable(address(distributeFunding)).transfer(fundingGoal);
    }

    receive () payable external {
        emit receivedFunds(msg.sender, msg.value);
    }

    fallback () external {
        emit fallbackCall("Falback Called!");
    }
}