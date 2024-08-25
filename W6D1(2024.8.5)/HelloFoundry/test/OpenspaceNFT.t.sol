// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/OpenspaceNFT.sol";

contract OpenspaceNFTTest is Test {
    OpenspaceNFT public nft;
    address public owner = address(0x123);
    address public user = address(0x456);

    function setUp() public {
        vm.prank(owner);
        nft = new OpenspaceNFT();
    }

    // function testInitialSetup() public{
    //     assertEq(nft.isPresaleActive(), true);
    //     assertEq(nft.nextTokenId(), 1);
    // }

    function testPresale() public {
        vm.prank(user);
        vm.deal(user, 1 ether);
        nft.presale{value: 0.01 ether}(1);
        assertEq(nft.balanceOf(user), 1);
        assertEq(nft.nextTokenId(), 2);
    }

    function testPresaleNotActive() public {
        vm.prank(owner);
        nft.enablePresale();
        vm.prank(user);
        vm.expectRevert("Presale is not active");
        nft.presale{value: 0.01 ether}(1);
    }

    function testPresaleInvalidAmount() public {
        vm.prank(user);
        vm.expectRevert("Invalid amount");
        nft.presale{value: 0.02 ether}(1);
    }

    function testPresaleNotEnoughTokens() public {
        vm.prank(user);
        vm.expectRevert("Not enough tokens left");
        nft.presale{value: 10.24 ether}(1024);
    }

    function testWithdraw() public {
        vm.prank(user);
        vm.deal(user, 1 ether);
        nft.presale{value: 0.01 ether}(1);

        uint256 balanceBefore = owner.balance;
        vm.prank(owner);
        nft.withdraw();
        uint256 balanceAfter = owner.balance;

        assertEq(balanceAfter, balanceBefore + 0.01 ether);
    }
}
