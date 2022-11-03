// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.15;

contract SponsorFunding {
    // uint sponsorBallance = 3000;
    uint percentSponsored;
    address private contractOwner;

    // events
    event fallbackCall(string);
    event receivedFunds(address, uint);

    constructor () payable {
        contractOwner = msg.sender;
        percentSponsored = 30;
        payable(address(this)).transfer(msg.value);
    }

    // change percentage
    function changeSponsorshipValue(uint _percentage) public {
        require(msg.sender == contractOwner, "Only the contract owner can change this value");

        percentSponsored = _percentage;
    }

    // add to ballance
    function addToBalance() payable external {
        require(msg.sender == contractOwner, "Only the contract owner can change this value");

        payable(address(this)).transfer(msg.value);
    }

    // donate
    function donate(uint _amount) payable public {
        uint extraSponsorshipAmount = _amount * percentSponsored / 100;
        require(extraSponsorshipAmount <= address(this).balance, "The amount exceeds our funds");
        
        payable(msg.sender).transfer(extraSponsorshipAmount);
    }

    receive () payable external {
        emit receivedFunds(msg.sender, msg.value);
    }

    fallback () external {
        emit fallbackCall("Falback Called!");
    }
}