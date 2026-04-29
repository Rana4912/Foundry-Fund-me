// SPDX-License-identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Before starBroadcast -> Not a "real" tx
        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        // After startBroadcast -> "real" tx

        vm.startBroadcast();
        // FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        FundMe fundMe = new FundMe(ethUsdPriceFeed);

        vm.stopBroadcast();
        return fundMe; // Return the variable so it's "used"
    }
}
