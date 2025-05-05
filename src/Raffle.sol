// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title A sample Raffle smart contract
 * @author Armin Siahmansour
 * @notice This contract is for creating a sample raffle
 * @dev Implement chainlink VRFv2.5
 */
contract Raffle {
    uint256 private immutable i_entranceFee;
    uint256 private immutable sag;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {}

    function pickWinner() public {}

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
