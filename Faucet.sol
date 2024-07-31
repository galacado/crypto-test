// SPDX-License-Identifier: CC-BY-SA-4.0

pragma solidity ^0.8.0;

contract Faucet {
    // Accept any incoming amount
    receive() external payable {}

    // Give out ether to anyone who asks
    function withdraw(uint withdraw_amount) public {
        // Limit withdrawal amount
        require(withdraw_amount <= 0.1 ether, "Withdrawal amount too large");

        // Send the amount to the address that requested it
        payable(msg.sender).transfer(withdraw_amount);
    }
}