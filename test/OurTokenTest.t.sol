// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    uint256 constant BOB_STARTING_AMOUNT = 100 ether;

    OurToken public ourToken;
    DeployOurToken public deployer;
    address public deployerAddress;
    address bob;
    address alice;
    address eve; // an address to test insufficient balance cases

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        bob = makeAddr("bob");
        alice = makeAddr("alice");
        eve = makeAddr("eve");

        deployerAddress = vm.addr(deployer.deployerKey());
        // Transfer some tokens from deployer to bob for testing
        vm.prank(deployerAddress);
        ourToken.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testOwnerCanMint() public {
        uint256 mintAmount = 50 ether;
        uint256 aliceBalanceBefore = ourToken.balanceOf(alice);
        // Assuming that the owner is the deployerAddress and that the token has a mint function callable by the owner.
        vm.prank(deployerAddress);
        // Mint tokens to alice
        MintableToken(address(ourToken)).mint(alice, mintAmount);
        uint256 aliceBalanceAfter = ourToken.balanceOf(alice);
        assertEq(aliceBalanceAfter, aliceBalanceBefore + mintAmount);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;
        // Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
    }

    function testTransfer() public {
        uint256 transferAmount = 10 ether;
        // Bob transfers tokens to Alice
        vm.prank(bob);
        // We also check for the Transfer event
        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, transferAmount);
        ourToken.transfer(alice, transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
    }

    function testTransferRevertsOnInsufficientBalance() public {
        uint256 transferAmount = BOB_STARTING_AMOUNT + 1 ether;
        vm.prank(bob);
        vm.expectRevert(); // expecting revert due to insufficient balance
        ourToken.transfer(alice, transferAmount);
    }

    function testApproveAndIncreaseAllowance() public {
        uint256 initialAllowance = 200;
        // Bob approves Alice for an allowance
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);
        assertEq(ourToken.allowance(bob, alice), initialAllowance);

        // Increase allowance by another 100 tokens by Bob
        uint256 additionalAllowance = 100;
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance + additionalAllowance);
        assertEq(ourToken.allowance(bob, alice), initialAllowance + additionalAllowance);
    }

    function testTransferFromRevertsOnExceedingAllowance() public {
        uint256 allowanceAmount = 300;
        // Bob approves Alice
        vm.prank(bob);
        ourToken.approve(alice, allowanceAmount);

        // Alice tries to transfer more than the approved amount
        vm.prank(alice);
        vm.expectRevert(); 
        ourToken.transferFrom(bob, alice, allowanceAmount + 1);
    }
}
