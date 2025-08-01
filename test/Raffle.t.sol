// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../src/Raffle.sol";
import {DeployRaffle} from "../script/DeployRaffle.s.sol";
import {HelperConfig, CodeConstants} from "../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFcoordinatorV2_5Mock.sol";

contract RaffleTest is CodeConstants, Test {
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
        vm.deal(address(raffle), 0);
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

    modifier raffleEntered() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}(); // give money to contract and add player
        vm.warp(block.timestamp + interval + 1); // set block.timestamp to block.timestamp+ interval + 1
        vm.roll(block.number + 1); //set block.number to block.number+1
        _;
    }

    function testEnterRaffleRevertWhenStateIsCalculating() public raffleEntered {
        //arrange
        raffle.performUpkeep(""); // call this to change the state to calculating ( we already pass the checkUpkeep conditions)

        //act/assert
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        raffle.enterRaffle{value: entranceFee}();
    }
    /*///////////////////////////////////////////CHECK UPKEEP//////////////////////////////////////////////*/

    function testCheckUpkeepReturnsFalseIfHasNoBalance() public {
        //arrange
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        //act
        (bool upkeepNeeded,) = raffle.checkUpkeep("");

        //assert
        assert(!upkeepNeeded);
    }

    function testCheckUpkeepReturnsFalseIfRaffleIsntOpen() public raffleEntered {
        //arrange
        raffle.performUpkeep("");

        //act
        (bool upkeepNeeded,) = raffle.checkUpkeep("");

        //assert
        assert(!upkeepNeeded);
    }

    function testCheckUpdkeepReturnsFalseIfEnoughTimeHasPassed() public {
        //arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

        //act
        (bool upkeepNeeded,) = raffle.checkUpkeep("");

        //assert
        assert(!upkeepNeeded);
    }

    function testCheckUpdkeepReturnsTrueWhenParametersAreGood() public raffleEntered {
        //arrange (done in modifier)

        //act
        (bool upkeepNeeded,) = raffle.checkUpkeep("");
        //assert
        assert(upkeepNeeded);
    }

    /*///////////////////////////////////////////PERFORM UPKEEP//////////////////////////////////////////////*/

    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() public raffleEntered {
        //arrange

        //act/assert
        raffle.performUpkeep("");
    }

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        //arange
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState raffleState = raffle.getRaffleState();

        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

        currentBalance = currentBalance + entranceFee;
        numPlayers = 1;

        //Act/assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__upkeepNotNeeded.selector, currentBalance, numPlayers, uint256(raffleState)
            )
        );
        raffle.performUpkeep("");
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public raffleEntered {
        //Act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        //Assert
        assert(uint256(requestId) > 0);
        assert(uint256(raffleState) == 1);
    }

    /*///////////////////////////////////////////Fulfill RandomWords//////////////////////////////////////////////*/

    modifier skipFork() {
        if (block.chainid != LOCAL_CHAIN_ID) {
            return;
        }
        _;
    }

    function testFullfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep(uint256 randomRequestId)
        public
        raffleEntered
        skipFork
    {
        //Arrange/Act/Assert
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(randomRequestId, address(raffle));
    }

    function testFulfillRandomWordsPickSWinnerResetsAndPayMoney() public raffleEntered skipFork {
        //Arrange
        uint256 additionalEntrants = 3; //4 total entrants
        uint256 startingIndex = 1;
        address expectedWinner = address(1);
        for (uint256 i = startingIndex; i < startingIndex + additionalEntrants; i++) {
            address entranceAddress = address(uint160(i));
            hoax(entranceAddress, 1 ether);
            raffle.enterRaffle{value: entranceFee}();
        }
        uint256 startingWinnerBalance = expectedWinner.balance;
        uint256 startingTimeStamp = raffle.getLastTimeStamp();

        //Act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(raffle));

        //Assert
        uint256 prize = (additionalEntrants + 1) * entranceFee;
        address recentWinner = raffle.getRecentWinner();
        uint256 endingWinnerBalance = recentWinner.balance;
        uint256 endingTimeStamp = raffle.getLastTimeStamp();
        Raffle.RaffleState raffleState = raffle.getRaffleState();

        assert(endingWinnerBalance == startingWinnerBalance + prize);
        assert(recentWinner == expectedWinner);
        assert(endingTimeStamp > startingTimeStamp);
        assert(uint256(raffleState) == 0);
    }
}
