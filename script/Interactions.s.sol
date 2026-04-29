// // Fund
// // Withdraw

// pragma solidity ^0.8.18;

// import {Script, console} from "forge-std/Script.sol";
// import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
// import {FundMe} from "../src/FundMe.sol";

// contract FundFundMe is Script {
//     uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000

//     function fundFundMe(address mostRecentlyDeployed) public payable {
//         FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();

//         console.log("Funded FundMe with %s", SEND_VALUE);
//     }

//     function run() external {
//         address mostRecentlyDeployedFundMe = DevOpsTools
//             .get_most_recent_deployment("FundMe", block.chainid);
//         vm.startBroadcast();
//         fundFundMe(mostRecentlyDeployedFundMe);
//         vm.stopBroadcast();
//     }
// }

// contract WithdrawFundMe is Script {
//     function withdrawFundMe(address mostRecentDeployed) public {
//         FundMe(payable(mostRecentDeployed)).withdraw();
//     }

//     function run() external {
//         address mostRecentlyDeployedFundMe = DevOpsTools
//             .get_most_recent_deployment("FundMe", block.chainid);

//         withdrawFundMe(mostRecentlyDeployedFundMe);
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        FundMe(payable(mostRecentlyDeployed)).withdraw();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}
