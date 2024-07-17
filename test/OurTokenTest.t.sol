// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken private ourToken;

    address private immutable i_bob = makeAddr("bob");
    address private immutable i_alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        DeployOurToken deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(i_bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(ourToken.balanceOf(i_bob), STARTING_BALANCE);
    }

    function testAliceBalance() public view {
        assertEq(ourToken.balanceOf(i_alice), 0);
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        // Bob approves Alice to spend tokens on her behalf
        vm.prank(i_bob);
        ourToken.approve(i_alice, initialAllowance);

        vm.prank(i_alice);
        ourToken.transferFrom(i_bob, i_alice, transferAmount);

        assertEq(ourToken.balanceOf(i_alice), transferAmount);
        assertEq(ourToken.balanceOf(i_bob), STARTING_BALANCE - transferAmount);
    }

    function testCannotTransferMoreThanAllowance() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 1500;

        vm.prank(i_bob);
        ourToken.approve(i_alice, initialAllowance);

        vm.prank(i_alice);
        vm.expectRevert();
        ourToken.transferFrom(i_bob, i_alice, transferAmount);
    }

    function testCannotTransferMoreThanBalance() public {
        uint256 transferAmount = STARTING_BALANCE + 1;

        vm.prank(i_bob);
        vm.expectRevert();
        ourToken.transfer(i_alice, transferAmount);
    }

    function testTransferBetweenAccounts() public {
        uint256 transferAmount = 50 ether;

        vm.prank(i_bob);
        ourToken.transfer(i_alice, transferAmount);

        assertEq(ourToken.balanceOf(i_alice), transferAmount);
        assertEq(ourToken.balanceOf(i_bob), STARTING_BALANCE - transferAmount);
    }

    function testCannotTransferToZeroAddress() public {
        uint256 transferAmount = 50 ether;

        vm.prank(i_bob);
        vm.expectRevert();
        ourToken.transfer(address(0), transferAmount);
    }
}
