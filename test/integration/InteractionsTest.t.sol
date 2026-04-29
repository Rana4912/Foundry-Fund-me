// pragma solidity ^0.8.18;

// import {Test, console} from "forge-std/Test.sol";
// import {FundMe} from "../../src/FundMe.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

// contract InteractionsTest is Test {
//     FundMe fundMe;

//     address USER = makeAddr("user");
//     uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
//     uint256 constant STARTING_BALANCE = 10 ether;
//     uint256 constant GAS_PRICE = 1;

//     function setUp() external {
//         // Deploy directly so test contract is the owner
//         HelperConfig helperConfig = new HelperConfig();
//         address priceFeed = helperConfig.activeNetworkConfig();

//         fundMe = new FundMe(priceFeed);
//         vm.deal(USER, STARTING_BALANCE);
//     }

//     function testUserCanFundInteractions() public {
//         FundFundMe fundFundMe = new FundFundMe();

//         vm.prank(USER);
//         fundFundMe.fundFundMe{value: SEND_VALUE}(address(fundMe));

//         uint256 balanceBefore = address(fundMe).balance;
//         assertEq(balanceBefore, SEND_VALUE);
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundAndWithdrawInteractions() public {
        // Fund as USER
        vm.startPrank(USER);
        vm.deal(USER, STARTING_BALANCE);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        // Withdraw as owner
        address owner = fundMe.getOwner();

        vm.startPrank(owner);
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
    }
}
