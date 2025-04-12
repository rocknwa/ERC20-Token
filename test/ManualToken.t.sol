// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/ManualToken.sol";

interface ITokenRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes calldata _extraData
    ) external;
}

/// @dev A dummy implementation of tokenRecipient to test approveAndCall.
contract DummyRecipient is ITokenRecipient {
    bool public approved;
    address public from;
    uint256 public valueReceived;
    address public tokenAddress;
    bytes public extraData;

    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes calldata _extraData
    ) external override {
        approved = true;
        from = _from;
        valueReceived = _value;
        tokenAddress = _token;
        extraData = _extraData;
    }
}

contract ManualTokenTest is Test {
    ManualToken public token;
    DummyRecipient public dummyRecipient;

    // Test addresses
    address public deployer = address(this);
    address public alice = address(0x1);
    address public bob = address(0x2);
    uint256 public initialSupply = 1000; // In tokens (constructor multiplies by 10^18)

    function setUp() public {
        // Deploy the ManualToken contract with the initial supply, name, and symbol.
        token = new ManualToken(initialSupply, "ManualToken", "MTK");
        dummyRecipient = new DummyRecipient();
    }

    function testInitialSupply() public view {
        uint256 expectedSupply = initialSupply * 10**18;
        assertEq(token.totalSupply(), expectedSupply, "Total supply should be initialSupply * 10^18");
        assertEq(token.balanceOf(deployer), expectedSupply, "Deployer should receive all initial tokens");
    }

    function testTransfer() public {
        uint256 transferAmount = 100 * 10**18;
        bool success = token.transfer(alice, transferAmount);
        assertTrue(success, "Transfer should succeed");
        assertEq(
            token.balanceOf(deployer),
            (initialSupply * 10**18) - transferAmount,
            "Deployer balance should decrease"
        );
        assertEq(token.balanceOf(alice), transferAmount, "Alice should receive the transferred tokens");
    }

    function testTransferFailsOnInsufficientBalance() public {
        // Bob has no tokens so transferring from Bob should revert.
        vm.prank(bob);
        vm.expectRevert();
        token.transfer(alice, 1);
    }

    function testApproveAndTransferFrom() public {
        uint256 approveAmount = 200 * 10**18;
        uint256 transferAmount = 150 * 10**18;

        // Deployer approves Bob to spend tokens on their behalf.
        bool approved = token.approve(bob, approveAmount);
        assertTrue(approved, "Approve should return true");
        assertEq(token.allowance(deployer, bob), approveAmount, "Allowance should be set correctly");

        // Bob calls transferFrom to transfer tokens from deployer to Alice.
        vm.prank(bob);
        bool transferred = token.transferFrom(deployer, alice, transferAmount);
        assertTrue(transferred, "transferFrom should succeed");

        assertEq(
            token.balanceOf(deployer),
            (initialSupply * 10**18) - transferAmount,
            "Deployer balance should decrease after transferFrom"
        );
        assertEq(token.balanceOf(alice), transferAmount, "Alice should receive the tokens");
        // The allowance should decrease accordingly.
        assertEq(token.allowance(deployer, bob), approveAmount - transferAmount, "Allowance should reduce after transferFrom");
    }

    function testApproveAndCall() public {
        uint256 approveAmount = 50 * 10**18;
        bytes memory extraData = "ExtraDataTest";

        // Calling approveAndCall should approve the dummy recipient and then trigger its callback.
        bool success = token.approveAndCall(address(dummyRecipient), approveAmount, extraData);
        assertTrue(success, "approveAndCall should return true");

        assertTrue(dummyRecipient.approved(), "Dummy recipient should have been notified");
        assertEq(dummyRecipient.from(), deployer, "Dummy recipient should receive deployer's address");
        assertEq(dummyRecipient.valueReceived(), approveAmount, "Dummy recipient should receive correct approve value");
        assertEq(dummyRecipient.tokenAddress(), address(token), "Dummy recipient should receive token address");
        assertEq(dummyRecipient.extraData(), extraData, "Dummy recipient should receive extra data");
    }

    function testBurn() public {
        uint256 burnAmount = 200 * 10**18;
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 balanceBefore = token.balanceOf(deployer);

        bool success = token.burn(burnAmount);
        assertTrue(success, "Burn should succeed");

        assertEq(token.balanceOf(deployer), balanceBefore - burnAmount, "Balance should decrease after burning");
        assertEq(token.totalSupply(), totalSupplyBefore - burnAmount, "Total supply should decrease after burning");
    }

    function testBurnFrom() public {
        // Transfer some tokens to Alice so that we can burn them from her account.
        uint256 transferAmount = 300 * 10**18;
        token.transfer(alice, transferAmount);

        // Alice approves Bob to burn tokens on her behalf.
        vm.prank(alice);
        token.approve(bob, transferAmount);

        uint256 burnAmount = 150 * 10**18;
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 totalSupplyBefore = token.totalSupply();

        vm.prank(bob);
        bool success = token.burnFrom(alice, burnAmount);
        assertTrue(success, "burnFrom should succeed");

        assertEq(
            token.balanceOf(alice),
            aliceBalanceBefore - burnAmount,
            "Alice's balance should decrease after burnFrom"
        );
        assertEq(
            token.totalSupply(),
            totalSupplyBefore - burnAmount,
            "Total supply should decrease after burnFrom"
        );
    }
}
