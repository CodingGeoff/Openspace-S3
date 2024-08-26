// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Liquidation.sol";
import "openzepplin-contracts/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";
contract LiquidationTest is Test {
    Liquidation public liquidation;
	address public debtAsset;
	address public collateralAsset;
	address public user;
	address public lendingPool;
    address public balancerValut;
    function setUp() public {
		// balancer v2 vault
		balancerValut = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
		// aave v2 lending pool
		lendingPool = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
        liquidation = new Liquidation(balancerValut, lendingPool);
		// MKR
		debtAsset = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
		// MANA
		collateralAsset = 0x0F5D2fB29fb7d3CFeE444a200298f468908cC942;
		// The address of the borrower getting liquidated
		user = 0xF2C5C39e4705DD3ECf306bb493736C94a42602Ae;
		// user = 0x97DD24d533a9cD956cF13f3B99307e9c1EF58b23;
		vm.label(balancerValut, "balancerValut");
		vm.label(lendingPool, "lendingPool");
		vm.label(address(liquidation), "liquidation");
		vm.label(debtAsset, "debtAsset");
		vm.label(collateralAsset, "collateralAsset");
		vm.label(user, "user");
    }

    function testDebtBalance() public {
		// console.log(address(liquidation));
		uint256 balance = IERC20(debtAsset).balanceOf(address(liquidation));
        assertEq(balance, 0);
    }

    function testCollateralAsset() public {
		uint256 balance = IERC20(collateralAsset).balanceOf(address(liquidation));
        assertEq(balance, 0);
    }
    function testHealthFactor() public {
		(, , , , , uint256 healthFactor) = ILendingPool(lendingPool).getUserAccountData(user);
		console.log("health factor", healthFactor);
		assertEq(healthFactor < 1 ether, true);
    }

	function testFlashloan() public {
		uint256 amount = 385664245699518349;
		liquidation.flashloan(debtAsset, amount, user, collateralAsset);
		uint256 balance = IERC20(debtAsset).balanceOf(address(liquidation));
		assertEq(balance > 0, true);
		console.log("Earned ", balance, "MKR");
	}
}

