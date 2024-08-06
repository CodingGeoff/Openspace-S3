// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet wallet;
    address owner1;
    address owner2;
    address owner3;
    address nonOwner;
    address[] public owners;

    function setUp() public {
        owner1 = makeAddr("Owner1");
        owner2 = makeAddr("Owner2");
        owner3 = makeAddr("Owner3");
        nonOwner = makeAddr("NonOwner");

        owners = [owner1, owner2, owner3];
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        wallet = new MultiSigWallet(owners, 2);
    }

    function testSubmitTransaction() public {
        // Owner中任意一人提交提案
        vm.prank(owner1);
        wallet.submitTransaction(address(0xdead), 1 ether);

        (address destination, uint value, bool executed) = wallet.transactions(0);
        assertEq(destination, address(0xdead));
        assertEq(value, 1 ether);
        assertFalse(executed);
    }

    function testConfirmTransaction() public {
        // Owner中任意一人确认提案
        vm.prank(owner1);
        wallet.submitTransaction(address(0xdead), 1 ether);

        vm.prank(owner2);
        wallet.confirmTransaction(0);

        bool isConfirmed = wallet.confirmations(0, owner2);
        assertTrue(isConfirmed);
    }

    function testExecuteTransactionByAnybody() public {
        // 达到多签门槛、任何人都可以执行交易
        vm.deal(address(wallet), 1 ether);

        vm.prank(owner1);
        wallet.submitTransaction(address(0xdead), 1 ether);

        vm.prank(owner2);
        wallet.confirmTransaction(0);

        vm.prank(owner3);
        wallet.confirmTransaction(0);

        vm.prank(nonOwner);
        wallet.executeTransaction(0);

        (address destination, uint value, bool executed) = wallet.transactions(0);
        assertTrue(executed);
        assertEq(address(0xdead).balance, 1 ether);
    }

    function testFailSubmitTransactionByNonOwner() public {
        vm.prank(nonOwner);
        // vm.expectRevert();   since the function name begins with testFail, we expect a revert
        wallet.submitTransaction(address(0xdead), 1 ether);
    }

    function testFailConfirmTransactionByNonOwner() public {
        vm.prank(owner1);
        wallet.submitTransaction(address(0xdead), 1 ether);

        vm.prank(nonOwner);
        wallet.confirmTransaction(0);
    }

    function testFailExecuteTransactionWithoutEnoughConfirmations() public {
        vm.deal(address(wallet), 1 ether);

        vm.prank(owner1);
        wallet.submitTransaction(address(0xdead), 1 ether);

        vm.prank(owner2);
        wallet.confirmTransaction(0);

        vm.prank(owner3);
        wallet.executeTransaction(0);
    }
}
