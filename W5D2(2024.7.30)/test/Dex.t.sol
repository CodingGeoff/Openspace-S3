// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {ERC20Mintable} from "./mocks/ERC20Mintable.sol";
import {UniswapV2Pair} from "../../src/UniswapV2/UniswapV2Pair.sol";
import {UniswapV2Factory} from "../../src/UniswapV2/UniswapV2Factory.sol";

contract UniswapV2PairTest is Test {
    ERC20Mintable token0;
    ERC20Mintable token1;
    UniswapV2Pair pair;
    TestUser testUser;
    address LP = address(this);
    address feeToSetter;

    function setUp() public {
        testUser = new TestUser();
        feeToSetter = makeAddr("feeToSetter");

        token0 = new ERC20Mintable("Token A", "TKNA");
        token1 = new ERC20Mintable("Token B", "TKNB");

        UniswapV2Factory factory = new UniswapV2Factory(feeToSetter);
        address pairAddress = factory.createPair(
            address(token0),
            address(token1)
        );
        pair = UniswapV2Pair(pairAddress);

        token0.mint(10 ether, LP);
        token1.mint(10 ether, LP);

        token0.mint(10 ether, address(testUser));
        token1.mint(10 ether, address(testUser));
    }

    function assertReserves(
        uint112 expectedReserve0,
        uint112 expectedReserve1
    ) internal {
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        assertEq(reserve0, expectedReserve0, "unexpected reserve0");
        assertEq(reserve1, expectedReserve1, "unexpected reserve1");
    }

    function testMintBootstrap() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        assertEq(pair.totalSupply(), 0);
        pair.mint(LP);

        assertEq(pair.balanceOf(address(this)), 1 ether - 1000);
        assertEq(pair.totalSupply(), 1 ether);
        assertReserves(1 ether, 1 ether);
    }

    function testMintWhenTheresLiquidity() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint(LP); // + 1 LP

        vm.warp(37);

        token0.transfer(address(pair), 2 ether);
        token1.transfer(address(pair), 2 ether);

        pair.mint(LP); // + 2 LP

        assertEq(pair.balanceOf(address(this)), 3 ether - 1000);
        assertEq(pair.totalSupply(), 3 ether);
        assertReserves(3 ether, 3 ether);
    }

    function testMintUnbalanced() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint(LP); // + 1 LP
        assertEq(pair.balanceOf(LP), 1 ether - 1000);
        assertReserves(1 ether, 1 ether);

        token0.transfer(address(pair), 2 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint(LP); // + 1 LP
        assertEq(pair.balanceOf(LP), 2 ether - 1000);
        assertReserves(3 ether, 2 ether);
    }

    function testBurn() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint(address(this));

        uint256 liquidity = pair.balanceOf(address(this));
        pair.transfer(address(pair), liquidity);
        assertEq(pair.balanceOf(address(this)), 0);
        assertEq(pair.balanceOf(address(pair)), liquidity);
        pair.burn(address(this));

        assertEq(pair.balanceOf(address(this)), 0);
        assertReserves(1000, 1000);
        assertEq(pair.totalSupply(), 1000);
        assertEq(token0.balanceOf(address(this)), 10 ether - 1000);
        assertEq(token1.balanceOf(address(this)), 10 ether - 1000);
    }

    function testBurnUnbalanced() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint(address(this));

        token0.transfer(address(pair), 2 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint(address(this)); // + 1 LP

        uint256 liquidity = pair.balanceOf(address(this));
        pair.transfer(address(pair), liquidity);
        pair.burn(address(this));

        assertEq(pair.balanceOf(address(this)), 0);
        assertReserves(1500, 1000);
        assertEq(pair.totalSupply(), 1000);
        assertEq(token0.balanceOf(address(this)), 10 ether - 1500);
        assertEq(token1.balanceOf(address(this)), 10 ether - 1000);
    }
}

contract TestUser {
    function provideLiquidity(
        address pairAddress_,
        address token0Address_,
        address token1Address_,
        uint256 amount0_,
        uint256 amount1_
    ) public {
        ERC20(token0Address_).transfer(pairAddress_, amount0_);
        ERC20(token1Address_).transfer(pairAddress_, amount1_);

        UniswapV2Pair(pairAddress_).mint(address(this));
    }

    function removeLiquidity(address pairAddress_) public {
        uint256 liquidity = ERC20(pairAddress_).balanceOf(address(this));
        ERC20(pairAddress_).transfer(pairAddress_, liquidity);
        UniswapV2Pair(pairAddress_).burn(address(this));
    }
}
