// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../src/Raffle.sol";
import {DeployRaffle} from "../script/DeployRaffle.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle private raffle;
    HelperConfig private helperConfig;

    address PLAYER = makeAddr("player");
    uint256 private constant PLAYER_STARTING_BALANCE = 10 ether;

    uint256 private entranceFee;
    uint256 private interval;
    address private vrfCoordinator;
    bytes32 private gasLane;
    uint32 private callbackGasLimit;
    uint256 private subscriptionId;

    event RaffleEnterd(address indexed player);
    event PickWinner(address indexed winner);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        callbackGasLimit = config.callbackGasLimit;
        subscriptionId = config.subscriptionId;
        vm.deal(PLAYER, PLAYER_STARTING_BALANCE);
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    /*///////////////////////////////////////////enter raffle//////////////////////////////////////////////*/

    function testEnterRaffleRevertWhenYouDontSentEnough() public {
        //arrange
        vm.prank(PLAYER);

        // act/assert
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
    }

    function testEnterRaffleRecordsPlayersWhenTheyEntered() public {
        //arrange
        vm.prank(PLAYER);

        //act
        raffle.enterRaffle{value: entranceFee}();

        //assert
        assert(raffle.getPlayer(0) == PLAYER);
    }

    function testEnterRaffleEmitEvent() public {
        //arrange
        vm.prank(PLAYER);

        //act/assert
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEnterd(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }
}
