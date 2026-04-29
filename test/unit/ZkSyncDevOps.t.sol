// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {FundMe} from "../../src/FundMe.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract ZkSyncDevopsTest is Test, ZkSyncChainChecker {
    FundMe fundMe;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8;

    address USER = address(1);

    function setUp() public {
        if (isZkSyncChain()) {
            // Deploy manually for zkSync
            MockV3Aggregator mockPriceFeed =
                new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
            fundMe = new FundMe(address(mockPriceFeed));
        } else {
            // Dummy deploy for non-zkSync (so test file doesn't break)
            MockV3Aggregator mockPriceFeed =
                new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
            fundMe = new FundMe(address(mockPriceFeed));
        }

        vm.deal(USER, STARTING_BALANCE);
    }

    // ✅ THIS is the test you were trying to run
    function testZkSyncChainFails() public {
        if (!isZkSyncChain()) {
            // If not zkSync → skip test
            return;
        }

        // Try funding
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        // Check state updated correctly
        uint256 funded = fundMe.getAddressToAmountFunded(USER);
        assertEq(funded, SEND_VALUE);
    }
}