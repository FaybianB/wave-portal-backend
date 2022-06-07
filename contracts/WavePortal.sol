// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaveCount;

    // Used to help generate a psuedo-random number
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        // The address of the user who waved.
        address waver;
        // The message the user sent.
        string message;
        // The timestamp when the user waved.
        uint256 timestamp;
    }

    Wave[] waves;

    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        // Set the initial seed
        // @TODO: Use Chainlink VRF to generate a random number
        seed = (block.timestamp + block.difficulty) % 100;
    }

    // @TODO: Implement reentrancy guard
    function wave(string memory _message) public {
        // Enforce a 30 second cool-down period to prevent user's spamming the contract with messages
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Must wait 30 seconds before waving again."
        );

        // Update the timestamp for the user
        lastWavedAt[msg.sender] = block.timestamp;
        totalWaveCount += 1;
        console.log("%s waved w/ message %s", msg.sender, _message);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        // Generate a new seed for the next user that sends a wave
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

        // Give a 50% chance that the user wins the prize.
        if (seed < 50) {
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;

            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );

            // Send the prize money to the user
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");

            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaveCount() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaveCount);

        return totalWaveCount;
    }
}