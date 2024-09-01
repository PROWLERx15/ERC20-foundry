// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address kd = makeAddr("kd");
    address mb = makeAddr("mb");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(kd, STARTING_BALANCE);
    }

    function testkdBalance() public view {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(kd));
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // kd approves mb to spend Tokens on his behalf
        vm.prank(kd);
        ourToken.approve(mb, initialAllowance);

        uint256 transferAmount = 500;
        vm.prank(mb);
        ourToken.transferFrom(kd, mb, transferAmount);
        assertEq(ourToken.balanceOf(mb), transferAmount);
        assertEq(ourToken.balanceOf(kd), STARTING_BALANCE - transferAmount);
    }

    function testTransfer() public {
        uint256 transferAmount = 500;
        uint256 initialBalance = ourToken.balanceOf(msg.sender);
        vm.prank(msg.sender);
        // Transfer tokens from msg.sender to kd
        ourToken.transfer(kd, transferAmount);

        // Check balances
        assertEq(
            ourToken.balanceOf(msg.sender),
            initialBalance - transferAmount
        );
        assertEq(ourToken.balanceOf(kd), STARTING_BALANCE + transferAmount);
    }
}
