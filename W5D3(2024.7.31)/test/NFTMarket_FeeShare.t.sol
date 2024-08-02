// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
// import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {NFTMarket_share} from "../src/NFTMarket_FeeShare.sol";
import {GeoNFT} from "../src/GeoNFT.sol";

contract NFTMarket_shareTest is Test {
    NFTMarket_share market;
    GeoNFT nft;
    address NFTowner;
    address NFTbuyer;  // nft buyer
    address staker_alice;
    address staker_bob;
    address staker_john;
    address staker_tom;

    function setUp() public {
        nft = new GeoNFT();
        market = new NFTMarket_share(nft);
        NFTowner = makeAddr("owner");
        NFTbuyer = makeAddr("buyer");
        staker_alice = makeAddr("Alice");
        staker_bob = makeAddr("Bob");
        staker_john = makeAddr("John");
        staker_tom = makeAddr("Tom");
    }


    // 测试铸造NFT
    function testBuyNFTbeforeAnyoneStake() public {
        vm.startPrank(NFTowner);
        uint256 id = nft.mint();
        assertEq(nft.ownerOf(id), NFTowner);
        nft.approve(address(market), id);
        market.listNFT(id, 1 ether);
        (uint256 price, address owner, bool is_listed) = market.nft_list(id);
        assertEq(price, 1 ether);
        // assertEq(is_listed, true);
        vm.stopPrank();
        vm.startPrank(NFTbuyer);
        vm.deal(NFTbuyer, 100 ether);
        market.buyNFT{value:1 ether}(id);
        assertEq(market.I_Accumulate(), 0);
        assertEq(market.TotalFee(), 0);
        vm.stopPrank();
    }
    
    function testBuyNFTAfterSomeoneStake_v1() public {
        vm.startPrank(staker_alice);
        vm.deal(staker_alice, 100 ether);
        market.stakeETH_v1{value: 2 ether}();
        (uint256 stake, uint256 unclaim, uint256 ini_I_Accumulate) = market.stakers_v1(staker_alice);
        assertEq(stake, 2 ether);
        vm.stopPrank();
        vm.startPrank(NFTowner);
        uint256 id = nft.mint();
        // address owner = ;
        // // console.log(owner);
        assertEq(nft.ownerOf(id), NFTowner);
        // assertEq(is_listed, false);
        nft.approve(address(market), id);
        market.listNFT(id, 1 ether);
        (uint256 price, address owner, bool is_listed) = market.nft_list(id);
        assertEq(price, 1 ether);
        // assertEq(is_listed, true);
        vm.stopPrank();
        vm.startPrank(NFTbuyer);
        vm.deal(NFTbuyer, 100 ether);
        market.buyNFT{value: 1 ether}(id);
        
        assertEq(market.TotalFee(), price*3/1000);
        vm.stopPrank();
    }

    function testManyPeopleStake_v1() public {
        vm.startPrank(staker_alice);
        vm.deal(staker_alice, 100 ether);
        market.stakeETH_v1{value: 2 ether}();
        (uint256 stake, uint256 unclaim, uint256 ini_I_Accumulate) = market.stakers_v1(staker_alice);
        assertEq(stake, 2 ether);
        vm.stopPrank();

        vm.startPrank(NFTowner);
        uint256 id = nft.mint();
        assertEq(nft.ownerOf(id), NFTowner);
        nft.approve(address(market), id);
        market.listNFT(id, 1 ether);
        (uint256 price, address owner, bool is_listed) = market.nft_list(id);
        assertEq(price, 1 ether);
        vm.stopPrank();

        vm.startPrank(NFTbuyer);
        vm.deal(NFTbuyer, 10000 ether);
        market.buyNFT{value: 1 ether}(id);
        assertEq(market.TotalFee(), price*3/1000);
        vm.stopPrank();

        
 
        vm.startPrank(staker_alice);
        market.unstakeETH_v1(1 ether);
        (stake, unclaim, ini_I_Accumulate) = market.stakers_v1(staker_alice);
        assertEq(stake, 1 ether);
        vm.stopPrank();
        vm.startPrank(staker_bob);
        vm.deal(staker_bob, 100 ether);
        market.stakeETH_v1{value: 6 ether}();
        (stake, unclaim, ini_I_Accumulate) = market.stakers_v1(staker_bob);
        assertEq(stake, 6 ether);
        vm.stopPrank();
    }
}

