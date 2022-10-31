// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.15;

contract DistributeFunding {
    uint totalPercentage;
    mapping(address => actionary) actionaries;
    address[] actionariesAddresses;

    struct actionary {
        uint percentage;
        string name;
    }

    // events
    event fallbackCall(string);
    event receivedFunds(address, uint);

    constructor () {
        totalPercentage = 0;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    // add actionary
    function addActionarry(uint _percentage, string calldata _name) public {
        // require that actionaries does not contain this address
        // require()
        require(totalPercentage <= 100, "No more actionaries can be added to this contract");
        require(totalPercentage + _percentage <= 100, "Could not be added as an actionary since the total percentage would be over 100");

        actionaries[msg.sender].percentage = _percentage;
        actionaries[msg.sender].name = _name;
    }

    function distributeMoney() payable external {
        require(address(this).balance > 0, "Can not distribute 0");

        for(uint i = 0; i < actionariesAddresses.length; ++i) {
            address actAddrs = actionariesAddresses[i];
            uint amountToTransfer = address(this).balance * actionaries[actAddrs].percentage / 100;

            payable(actAddrs).transfer(amountToTransfer);
        }
    }

    receive () payable external {
        emit receivedFunds(msg.sender, msg.value);
    }

    fallback () external {
        emit fallbackCall("Falback Called!");
    }
}