// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/SmartBank.sol";

contract SmartBankTest is Test {
    SmartBank public bank;

    address account1 = address(0x1);
    address account2 = address(0x2);
    address account3 = address(0x3);
    address account4 = address(0x4);
    address account5 = address(0x5);
    address account6 = address(0x6);
    address account7 = address(0x7);
    address account8 = address(0x8);
    address account9 = address(0x9);
    address account10 = address(0xa);

    // address account1 = makeAddr("Account1");
    // address account2 = makeAddr("Account2");
    // address account3 = makeAddr("Account3");
    // address account4 = makeAddr("Account4");
    // address account5 = makeAddr("Account5");
    // address account6 = makeAddr("Account6");
    // address account7 = makeAddr("Account7");
    // address account8 = makeAddr("Account8");
    // address account9 = makeAddr("Account9");
    // address account10 = makeAddr("Account10");

    function setUp() public {
        bank = new SmartBank();
        vm.label(address(bank), "SmartBankContract");
    }

    function testDeposit() public {
        vm.deal(account1, 5 ether);
        vm.startPrank(account1);
        bank.Deposit{value: 1 ether}();
        assertEq(bank.balances(account1), 1 ether);
        bank.Deposit{value: 2 ether}();
        assertEq(bank.balances(account1), 3 ether);
        vm.stopPrank();
    }

    // function testWithdraw() public {
    //     vm.startPrank(account1);
    //     bank.Deposit{value: 3 ether}();
    //     bank.Withdraw(1 ether);
    //     vm.stopPrank();
    // }
    // [PrecompileOOG] EvmError: PrecompileOOG: Precompiled contract returned an error. (see Yellow Paper Rev. Jan. 2019).

    function testRemoveAccount() public {
        vm.deal(account1, 5 ether);
        vm.startPrank(account1);
        bank.Deposit{value: 3 ether}();
        bank.removeAccount();
        assertEq(bank.balances(account1), 0);
        assertEq(bank.totalAccounts(), 0);
        vm.stopPrank();
    }

    function testGetTopAccounts() public {
        vm.deal(account1, 1000 ether);
        vm.deal(account2, 1000 ether);
        vm.deal(account3, 1000 ether);
        vm.deal(account4, 1000 ether);
        vm.deal(account5, 1000 ether);
        vm.deal(account6, 1000 ether);
        vm.deal(account7, 1000 ether);
        vm.deal(account8, 1000 ether);
        vm.deal(account9, 1000 ether);
        vm.deal(account10, 1000 ether);

        vm.prank(account1);
        bank.Deposit{value: 1 ether}();
        vm.prank(account2);
        bank.Deposit{value: 2 ether}();
        vm.prank(account3);
        bank.Deposit{value: 1.5 ether}();
        vm.prank(account4);
        bank.Deposit{value: 50 ether}();

        vm.startPrank(account5);
        bank.Deposit{value: 1000 ether}();
        console.log("address(bank).balance(when user deposit)", address(bank).balance); 
        bank.Withdraw(1 ether);
        vm.stopPrank();

        vm.prank(account6);
        bank.Deposit{value: 999 ether}();
        vm.prank(account7);
        bank.Deposit{value: 0.1 ether}();
        vm.prank(account8);
        bank.Deposit{value: 0.01 ether}();
        vm.prank(account9);
        bank.Deposit{value: 300 ether}();
        vm.prank(account10);
        bank.Deposit{value: 400 ether}();

        address[] memory topAccounts = bank.getTopAccounts(4);
        assertEq(topAccounts[0], account5);
        assertEq(topAccounts[1], account6);
        assertEq(topAccounts[2], account10);
        assertEq(topAccounts[3], account9);
        // console.log(address(bank).balance);


        vm.startPrank(account5);
        bank.Withdraw(998 ether);
        console.log("address(bank).balance(when user withdraw)", address(bank).balance); 
        vm.stopPrank();
        topAccounts = bank.getTopAccounts(4);
        assertEq(topAccounts[0], account6);
        assertEq(topAccounts[1], account10);
        assertEq(topAccounts[2], account9);
        assertEq(topAccounts[3], account4);
    }

}
