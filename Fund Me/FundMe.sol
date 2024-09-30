// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./PriceConverter.sol";

// 1 ether = 1e18

// error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;

    constructor(){
        owner = msg.sender;
    }

    function fund() public payable{
        require(msg.value.getConversionRate() >= minimumUsd, "Didn't send enough ether :("); 
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner{
        for(uint256 i = 0; i < funders.length; i++){
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }

        // reset the array
        funders = new address[](0);

        // transfer:
        // payable(msg.sender).transfer(address(this).balance);
        
        // send:
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed :(");

        // call: recommended
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed :(");
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Sender is not owner!!");
        _;
    }
}