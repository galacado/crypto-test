// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address public immutable i_owner;
    address[] public s_funders;
    mapping(address => uint256) public s_addressToAmountFunded;
    AggregatorV3Interface public s_priceFeed;

    modifier onlyOwner {
        if(msg.sender != i_owner) { revert FundMe__NotOwner(); }
        _;
    }
    
    constructor(address priceFeedAddress){
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    receive() external payable { fund(); }

    fallback() external payable { fund(); }

    function fund() public payable{
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Didn't send enough ether :("); 

        for(uint256 i = 0; i < s_funders.length; i++){
            if(s_funders[i] == msg.sender){
                s_addressToAmountFunded[msg.sender] += msg.value;
            }
            else{
                s_funders.push(msg.sender);
                s_addressToAmountFunded[msg.sender] = msg.value;
            }
        }
    }

    function withdraw() public onlyOwner{
        for(uint256 i = 0; i < s_funders.length; i++){
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed :(");
    }
}