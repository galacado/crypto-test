// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./PriceConverter.sol";

// 1 ether = 1e18

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable{
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough ether :("); 

        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);

        // Test this:
        // for(uint256 i = 0; i < funders.length; i++){
        //     if(funders[i] == msg.sender){
        //         addressToAmountFunded[msg.sender] += msg.value;
        //     }
        //     else{
        //         funders.push(msg.sender);
        //         addressToAmountFunded[msg.sender] = msg.value;
        //     }
        // }
    }

    function withdraw() public onlyOwner{
        for(uint256 i = 0; i < funders.length; i++){
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }

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
        // require(msg.sender == i_owner, "Sender is not owner!!");
        if(msg.sender != i_owner) { revert NotOwner(); }
        _;
    }

    receive() external payable { fund(); }

    fallback() external payable { fund(); }
}