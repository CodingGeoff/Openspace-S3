// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;
// import "forge-std/Test.sol";
// import "../src/Bank.sol";
// contract BankTest is Test {
//     Bank bank;
//     address owner;
//     address user;
//     uint public initialETHBalance;
//     uint public receivedETH;

//     event LogDeposit(uint amount);

//     function setUp() public {
//         owner = makeAddr("Tom");
//         user = makeAddr("Alice");
//         bank = new Bank(owner);
//         initialETHBalance = address(this).balance;
//         // bank.setDepositor(address(this));
//     }

//     function testReceiveEther() public {
//         // Ensure the current address to pay is this contract.
//         // assertEq(bank.depositor(), address(this));
//         // Send 1 ether as donation.
//         vm.deal(user, 2 ether);
//         vm.startPrank(user);
//         (bool success,) = address(bank).call{value: 1 ether}("");
//         address(bank).call{value: 1 ether}(abi.encodeWithSignature("deposit()"));  
//         vm.stopPrank();
//         vm.prank(owner);
//         bank.withdraw(user, 1 ether);
//         // address(bank).call(abi.encodeWithSignature("withdraw(address, uint256)"));  





//             // deposit{value: 1 ether}();
//         // assertEq(success, true);
//         // Check that the current contract received the money.
//         // assertEq(address(this).balance, initialETHBalance + 1 ether);
//     }
// }