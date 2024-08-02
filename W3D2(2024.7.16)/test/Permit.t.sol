// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ERC2612_Permit.sol";
import "../src/DepositBank_Permit.sol";
import "../src/NFTMarket_Permit.sol";
import "../src/GeoNFT.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SimpleNFTMarketTest is Test {
    NFTMarket_Permit market;
    GeoToken geoToken;
    GeoNFT nft;
    address seller;
    address buyer;

    function setUp() public {
        geoToken = new GeoToken();
        nft = new GeoNFT();
        market = new NFTMarket_Permit(geoToken, nft);
        seller = address(0x1);
        buyer = address(0x2);

        // Mint NFT to seller
        vm.startPrank(seller);
        uint256 id = nft.mint();
        // IERC721(nft)._mint(seller, 1);
        nft.approve(address(market), id);
        vm.stopPrank();

        // Mint tokens to buyer
        vm.startPrank(buyer);
        geoToken.mint(buyer, 1000 ether);
        geoToken.approve(address(market), 1000 ether);
        vm.stopPrank();
    }

    function testCreateListing() public {
        vm.startPrank(seller);
        uint256 id = nft.mint();
        market.createListing(id, address(geoToken), 100 ether, block.timestamp + 1 days);
        bytes32 listingId = market.getListing(id);
        assertTrue(listingId != bytes32(0));
        vm.stopPrank();
    }

    function testCancelListing() public {
        vm.startPrank(seller);
        uint256 id = nft.mint();
        market.createListing(id, address(geoToken), 100 ether, block.timestamp + 1 days);
        bytes32 listingId = market.getListing(id);
        market.cancelListing(listingId);
        assertTrue(market.getListing(id) == bytes32(0));
        vm.stopPrank();
    }

    function testPurchase() public {
        vm.startPrank(seller);
        uint256 id = nft.mint();
        
        market.createListing(id, address(geoToken), 100 ether, block.timestamp + 1 days);
        bytes32 listingId = market.getListing(id);
        vm.stopPrank();

        vm.startPrank(buyer);
        market.purchase(listingId);
        assertTrue(nft.ownerOf(id) == buyer);
        vm.stopPrank();
    }
}
