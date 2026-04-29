// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import  {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundMeTest  is Test {
      FundMe fundMe;

      address USER = makeAddr("user");
      uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
      uint256 constant STARTING_BALANCE = 10 ether;
      uint256 constant GAS_PRICE = 1;

      function setUp() external {
        // us -> FundMeTest -> FundMe
        //  fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
      }

      // function testDemo() public {
      //   console.log(number);
      //   console.log("hi mom!");
      //   assertEq(number, 2);
      // }

      function testMinimumDoallarIsFive() public view {
          assertEq(fundMe.MINIMUM_USD(), 5e18);
      }

      function testOwnerIsMsgSender() public view {
        console.log("Owner: ", fundMe.getOwner());
        console.log("Msg Sender: ", msg.sender);
        // assertEq(fundMe.i_owner(), msg.sender);
        // the above will not work because the
        // test contract is the one that deploys the FundMe contract, so the owner will be the test contract, not the address that calls the test function. so we need to use the address of the test contract, which is address(this) 
        // assertEq(fundMe.i_owner(), address(this));
        assertEq(fundMe.getOwner(), msg.sender);
        
      }

      // What can we do to work with addresses outside our system?
// 1. Unit
//    - Testing a specific part of our code
// 2. Integration
//    - Testing how our code works with other parts of our code
// 3. Forked
//    - Testing our code on a simulated real environment
// 4. Staging
//    - Testing our code in a real environment that is not production

      // function testPriceFeedVersionIsAccurate() public view{
      //   uint256 version = fundMe.getVersion();
      //   assertEq(version, 4);
        
      // }

        function testPriceFeedVersionIsAccurate() public view {
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }
  }  

        function testFundFailsWithoutEnoughETH() public {
          vm.expectRevert(); // hey, the next line , should revert!
          // assert(This tx fails/reverts)
          fundMe.fund();//send 0 value
        }   

        function testFundUpdatesFundedDataStructure() public {
          vm.prank(USER); // next tx will be sent by USER
          fundMe.fund{value: SEND_VALUE}(); // send 1 ETH
          uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
          assertEq(amountFunded, SEND_VALUE);
        }  

        function testAddsFunderToArrayOfFunders() public{
          vm.prank(USER); // next tx will be sent by USER
          fundMe.fund{value: SEND_VALUE}(); // send 1 ETH
          address funder = fundMe.getFunder(0);
          assertEq(funder, USER);
        }


        // function testOnlyOwnerCanWithdraw() public {
        //   vm.prank(USER); // next tx will be sent by USER
        //   fundMe.fund{value: SEND_VALUE}(); // send 1 ETH

        //   vm.expectRevert(); // hey, the next line , should revert!
        //   vm.prank(USER); // next tx will be sent by USER
        //   fundMe.withdraw();
          
        // }

        modifier funded() {
          vm.prank(USER); // next tx will be sent by USER
          fundMe.fund{value: SEND_VALUE}(); // send 1 ETH
          _;
          
        }

        function testOnlyOwnerCanWithdraw() public funded {
          vm.expectRevert(); // hey, the next line , should revert!
          vm.prank(USER); // next tx will be sent by USER
          fundMe.withdraw();
          
        }

        function testWithDrawWithASingleFunder()public funded {
          // Arrange
          uint256 startingOwnerBalance = fundMe.getOwner().balance;
          uint256 startingFundMeBalance = address(fundMe).balance;

          // Act
          // uint256 gasStart = gasleft(); //1000
          // vm.txGasPrice(GAS_PRICE); // set the gas price for the next transaction
          vm.prank(fundMe.getOwner());//c: 200 // next tx will be sent by owner
          fundMe.withdraw(); // should have spen gas?

          // uint256 gasEnd = gasleft(); // 800
          // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; 
          // console.log("Gas Used: ", gasUsed);
          

          // Assert
          uint256 endingOwnerBalance = fundMe.getOwner().balance;
          uint256 endingFundMeBalance = address(fundMe).balance;  
          assertEq(endingFundMeBalance, 0);
          assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);

        }

        function testWithdrawFromMultipleFunders() public funded {
          uint160 numberOfFunders = 10;
          uint160 startingFunderIndex = 1;
          for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            // vm.prank new address
            // vm.deal new address with some eth
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
             }
            // fund the fundMe contract with that new address

          uint256 startingOwnerBalance = fundMe.getOwner().balance;
          uint256 startingFundMeBalance = address(fundMe).balance;
          
          //Act

          vm.startPrank(fundMe.getOwner()); // next tx will be sent by owner
          fundMe.withdraw();
          vm.stopPrank();

          // Assert
          assert(address(fundMe).balance == 0);
          assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
         
        }


        function testWithdrawFromMultipleFundersCheaper() public funded {
          uint160 numberOfFunders = 10;
          uint160 startingFunderIndex = 1;
          for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            // vm.prank new address
            // vm.deal new address with some eth
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
             }
            // fund the fundMe contract with that new address

          uint256 startingOwnerBalance = fundMe.getOwner().balance;
          uint256 startingFundMeBalance = address(fundMe).balance;
          
          //Act

          vm.startPrank(fundMe.getOwner()); // next tx will be sent by owner
          fundMe.cheaperWithdraw();
          vm.stopPrank();

          // Assert
          assert(address(fundMe).balance == 0);
          assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
         
        }
        
}