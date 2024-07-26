// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RNTIDO.sol";
import "forge-std/console.sol";

contract RNTIDOTest is Test {
    RNTIDO public rntido;
    RNT public rnt;
    address public owner = makeAddr("owner");
    address public contributor1 = makeAddr("contributor1");
    address public contributor2 = makeAddr("contributor2");

    function setUp() public {
        vm.startPrank(owner);
        rntido = new RNTIDO(1 weeks);
        vm.deal(owner, 3000 ether);
        vm.deal(contributor1, 100 ether);
        vm.deal(contributor2, 200 ether);
        vm.stopPrank();
        // vm.startPrank(address(rnt.owner()));
        // rnt.transfer(address(rntido), rntido.RNT_SUPPLY());
        // vm.stopPrank();

    }

    function tearDown() public {
        // return funds to owner
    }

    function testInitialSetup() public view {
        assertEq(rntido.owner(), owner);
        assertEq(rntido.isFinalized(), false);
    }

    function testContribute() public {
        vm.prank(contributor1);
        rntido.contribute{value: 0.05 ether}();

        assertEq(rntido.contributions(contributor1), 0.05 ether);
        assertEq(address(rntido).balance, 0.05 ether);
    }

    function testWithdrawFundsFailure() public {
        vm.prank(contributor1);
        rntido.contribute{value: 0.1 ether}();

        vm.warp(block.timestamp + 1 weeks);
        rntido.finalize();

        vm.prank(owner);
        vm.expectRevert("Funding goal not reached");
        rntido.withdrawFunds();
        // rntido.withdrawFunds(0.1 ether);
    }

    // todo: test success ido

    // function testFinalizeSuccess() public {
    //     address(rntido).call{value: 100 ether};
    //     vm.startPrank(contributor1);
    //     rntido.contribute{value: 0.1 ether};

    //     // for (uint256 i = 0; i < 8; i++) {
    //     //     rntido.contribute{value: 0.1 ether}();
    //     //     console.log(address(rntido).balance);
    //     // }
    //     vm.stopPrank();
    //     console.log("ido balance:", address(rntido).balance);
    //     // vm.warp(block.timestamp + 0.1 weeks);
    //     rntido.finalize();

    //     assertEq(rntido.isFinalized(), true);
    // }

    function testExceedTimeLimit() public {
        vm.warp(block.timestamp + 4 weeks);
        vm.prank(contributor1);
        vm.expectRevert("IDO has ended");
        rntido.contribute{value: 0.1 ether}();
        rntido.finalize();
        assertEq(rntido.isFinalized(), false);
    }


    // todo: enable test on exceeding funding goals
    function testExceedFundingGoal() public {
        vm.prank(address(rntido.owner()));
        rntido.admin_contribute{value: 400 ether}();
        vm.prank(contributor1);
        vm.expectRevert("Funding cap reached");
        rntido.contribute{value: 0.1 ether}();
        vm.warp(block.timestamp + 1 weeks);
        rntido.finalize();

        assertEq(rntido.isFinalized(), false);
    }

    function testFinalizeFailure() public {
        vm.prank(contributor1);
        rntido.contribute{value: 0.1 ether}();

        vm.warp(block.timestamp + 1 weeks);

        rntido.finalize();

        assertEq(rntido.isFinalized(), false);
    }

    function testClaimTokensSuccess() public {
        vm.prank(contributor1);

        rntido.contribute{value: 0.1 ether}();
        vm.prank(address(rntido.owner()));
        rntido.admin_contribute{value: 0.5 ether}();

        vm.warp(block.timestamp + 1 weeks);
        rntido.finalize();
        vm.startPrank(owner);
        rntido.withdrawFunds();
        console.log("ETH balance of owner", address(owner).balance);
        rntido.withdrawFunds();
        console.log("ETH balance of owner", address(owner).balance);
        vm.stopPrank();
        vm.prank(contributor1);
        rntido.claim();
        // console.log("", address(contributor1));
    }
    function testClaimTokensFailure() public {
        vm.prank(contributor1);
        rntido.contribute{value: 0.1 ether}();

        vm.warp(block.timestamp + 1 weeks);
        rntido.finalize();

        vm.prank(contributor1);
        vm.expectRevert("Funding goal not reached");
        rntido.claim();
    }

    function testRefund() public {
        vm.prank(contributor1);
        rntido.contribute{value: 0.05 ether}();
        vm.assertEq(address(rntido).balance, 0.05 ether);
        vm.assertEq(address(contributor1).balance, 99.95 ether);

        vm.warp(block.timestamp + 1 weeks);
        rntido.finalize();

        vm.prank(contributor1);
        rntido.refund();

        assertEq(rntido.contributions(contributor1), 0);
    }

    function testInvestFailure() public {
        vm.prank(contributor1);
        vm.expectRevert("Contribution too low");
        rntido.contribute{value: 0.001 ether}();
        vm.prank(contributor2);
        vm.expectRevert("Contribution too high");
        rntido.contribute{value: 2 ether}();
    }


    // todo: test withdraw funds
    // todo: test claim tokens
    // todo: test refund
    // // the same issue
    function testWithdrawFundsSuccess() public {
        vm.prank(address(rntido.owner()));
        rntido.admin_contribute{value: 0.5 ether}();
        vm.prank(contributor1);
        rntido.contribute{value: 0.1 ether}();
        vm.startPrank(contributor2);
        rntido.contribute{value: 0.05 ether}();
        vm.warp(block.timestamp + 0.3 weeks);
        rntido.finalize();
        vm.stopPrank();
        vm.startPrank(owner);
        // todo: why is it illegal?
        uint256 Before_claim = address(owner).balance;
        console.log("Before the owner claim ETH:", address(owner).balance);
        rntido.withdrawFunds();
        uint256 After_claim = address(owner).balance;
        console.log("After the owner claim ETH:", address(this).balance);
        console.log("The amount of ETH claimed by the owner:", After_claim-Before_claim );
        vm.stopPrank();
    }
}
