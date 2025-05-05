// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title A sample Raffle smart contract
 * @author Armin Siahmansour
 * @notice This contract is for creating a sample raffle
 * @dev Implement chainlink VRFv2.5
 */
contract Raffle {
    error Raffle__SendMoreToEnterRaffle();
    uint256 private immutable i_entranceFee;
    uint256 private immutable sag;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        // require(msg.value>=i_entranceFee,"send more money to enter the raffle"); //Not optimize cause we need do store a string
        // require(msg.value>=i_entranceFee,Raffle__SendMoreToEnterRaffle()); //1-only after solidity 0.18.26
        //2-need a complex compiler to run and take more time to compile 3= more gas and not optimized.

        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
    }

    function pickWinner() public {}

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
