// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

//imports
import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFcoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

abstract contract CodeConstants {
    /*VRF Mock Values */
    uint96 constant MOCK_BASE_FEE = 0.25 ether;
    uint96 constant MOCK_GAS_PRICE_LINK = 1e9;
    //Link / ETH price
    int256 constant MOCK_WEI_PER_UNIT_LINK = 4e15;

    uint256 constant ETH_SEPLIA_CHAIN_ID = 11155111;
    uint256 constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    //Errors
    error HelperConfig__InvalidChinId();

    //Type Declarions
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        uint256 subscriptionId;
        address link;
        address account;
    }

    //State variables
    NetworkConfig private localNetworkConfig;
    mapping(uint256 => NetworkConfig) private networkConfigs;

    //functions
    constructor() {
        networkConfigs[ETH_SEPLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfigByChainId(uint256 chainId) private returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilConfig();
        } else {
            revert HelperConfig__InvalidChinId();
        }
    }

    function getConfig() external returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getSepoliaEthConfig() private pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether, //1e16
            interval: 30, //30 seconds
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 500000,
            subscriptionId: 107372204690343301928851391998760513193819193865445417473167254335401396381073,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            account: 0x0e5284Ba5E3432A45Ccb593F09dFd03F5b770A13
        });
    }

    function getOrCreateAnvilConfig() private returns (NetworkConfig memory) {
        //check to see if we set an active local network config before
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock =
            new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UNIT_LINK);
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether, //1e16
            interval: 30, //30 seconds
            vrfCoordinator: address(vrfCoordinatorMock),
            //gasLane value doesnt matter
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            callbackGasLimit: 500000,
            subscriptionId: 0,
            link: address(linkToken),
            account: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
        });
        return localNetworkConfig;
    }
}
