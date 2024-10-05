// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentIntermediary {
    struct Payment {
        uint256 amount;
        address recipient;
        uint256 releaseTime;
    }

    mapping(address => Payment) public payments;

    function deposit(address recipient, uint256 releaseTime) external payable {
        require(msg.value > 0, "Must send some Ether");
        require(releaseTime > block.timestamp, "Release time must be in the future");
        require(payments[msg.sender].amount == 0, "Existing payment pending");

        payments[msg.sender] = Payment({
            amount: msg.value,
            recipient: recipient,
            releaseTime: releaseTime
        });
    }

    function release() external {
        Payment memory payment = payments[msg.sender];
        require(payment.amount > 0, "No payment to release");
        require(block.timestamp >= payment.releaseTime, "Release time not reached");

        delete payments[msg.sender];
        payable(payment.recipient).transfer(payment.amount);
    }

    function withdraw() external {
        Payment memory payment = payments[msg.sender];
        require(payment.amount > 0, "No payment to withdraw");

        delete payments[msg.sender];
        payable(msg.sender).transfer(payment.amount);
    }
}
