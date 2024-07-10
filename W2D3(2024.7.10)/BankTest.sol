// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Bank.sol";

contract BankTest is Test {
    Bank bank;

    function setUp() public {
        bank = new Bank();
    }

    function testDepositETH() public {
        uint initialBalance = bank.balanceOf(address(this));
        uint depositAmount = 1 ether;

        vm.expectEmit(true, true, false, true);
        emit Bank.Deposit(address(this), depositAmount);

        bank.depositETH{value: depositAmount}();

        assertEq(bank.balanceOf(address(this)), initialBalance + depositAmount);
        assertEq(address(bank).balance, depositAmount);

        uint secondDepositAmount = 2 ether;
        vm.expectEmit(true, true, false, true);
        emit Bank.Deposit(address(this), secondDepositAmount);
        bank.depositETH{value: secondDepositAmount}();

        assertEq(bank.balanceOf(address(this)), initialBalance + depositAmount + secondDepositAmount);
        assertEq(address(bank).balance, depositAmount + secondDepositAmount);
    }

    function testDepositETHFromDifferentUser() public {
        address newUser = address(0x123);
        vm.deal(newUser, 1 ether);

        uint initialBalance = bank.balanceOf(newUser);
        uint depositAmount = 1 ether;

        vm.expectEmit(true, true, false, true);
        emit Bank.Deposit(newUser, depositAmount);

        vm.prank(newUser);
        bank.depositETH{value: depositAmount}();

        assertEq(bank.balanceOf(newUser), initialBalance + depositAmount);
        assertEq(address(bank).balance, depositAmount);
    }

    function testDepositZeroETH() public {
        vm.expectRevert("Deposit amount must be greater than 0");
        bank.depositETH{value: 0}();
    }

    function testDepositExcessiveETH() public {
        uint excessiveAmount = address(this).balance + 1 ether;
        vm.expectRevert();
        bank.depositETH{value: excessiveAmount}();
    }

    function testMultipleDeposits() public {
        uint initialBalance = bank.balanceOf(address(this));
        uint depositAmount1 = 0.5 ether;
        uint depositAmount2 = 1.5 ether;

        bank.depositETH{value: depositAmount1}();
        bank.depositETH{value: depositAmount2}();

        assertEq(bank.balanceOf(address(this)), initialBalance + depositAmount1 + depositAmount2);
        assertEq(address(bank).balance, depositAmount1 + depositAmount2);
    }
}



// contract Bank {
//     mapping(address => uint) public balanceOf;
//     event Deposit(address indexed user, uint amount);
//     function depositETH() external payable {
//         require(msg.value > 0, "Deposit amount must be greater than 0");
//         balanceOf[msg.sender] += msg.value;
//         emit Deposit(msg.sender, msg.value);
//     }
// }
