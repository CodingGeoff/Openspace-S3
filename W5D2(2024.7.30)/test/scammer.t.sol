// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;
// import "../src/scammer.sol";
// import "forge-std/Test.sol";
// import "forge-std/console.sol";
// contract scammer_test is Test(){
//     address scammer;
//     address poorguy;
//     CarlsETHFlashloan scamflashloan;
//     function setUp() public {
     
//         poorguy = makeAddr("Alice");
//         scamflashloan = new CarlsETHFlashloan("ge","gc",20000);
//     }


//     // 测试铸造NFT
//     function testscam() public {
//         vm.deal(poorguy, 100000 ether);
//         vm.prank(poorguy);
//         scamflashloan.action{value: 100 ether}();
//         console.log(address(scamflashloan).balance);
//     }
// }

