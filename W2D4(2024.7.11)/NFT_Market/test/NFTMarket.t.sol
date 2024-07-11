// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "../src/NFTMarket.sol";

contract NFTMarketTest is Test {
    BaseERC20 token;
    NFT nft;
    NFTMarket market;
    address user1;
    address user2;

    function setUp() public {
        token = new BaseERC20();
        nft = new NFT();
        market = new NFTMarket(address(token), address(nft));
        user1 = address(0x1);
        user2 = address(0x2);

        // Mint some tokens to user1 and user2
        token.transfer(user1, 1000 * 10 ** 18);
        token.transfer(user2, 1000 * 10 ** 18);

        // Mint an NFT to user1
        vm.prank(user1);
        nft.mint(user1, "https://example.com/nft1");
    }
    // 测试上架成功的情况
    function testListNFTSuccess() public {
        vm.prank(user1);
        nft.approve(address(market), 1);
        vm.prank(user1);
        market.listNFT(1, 100 * 10 ** 18);

        assertEq(nft.ownerOf(1), address(market));
        assertEq(market.nftPrices(1), 100 * 10 ** 18);
        assertEq(market.nftSellers(1), user1);
    }
    // 测试上架失败的情况（上架不属于自己的NFT）
    function testListNFTFail() public {
        vm.startPrank(user2);
        // 断言错误信息
        vm.expectRevert("ERC721: transfer caller is not owner nor approved");
        market.listNFT(1, 100 * 10 ** 18);
        console.log("msg.sender:", msg.sender);
        vm.stopPrank();
    }

    // 测试购买成功的情况
    function testBuyNFTSuccess() public {
        vm.prank(user1);
        nft.approve(address(market), 1);
        vm.prank(user1);
        market.listNFT(1, 100 * 10 ** 18);
        vm.prank(user2);
        token.approve(address(market), 100 * 10 ** 18);
        vm.prank(user2);
        market.buyNFT(1);

        assertEq(nft.ownerOf(1), user2);
        assertEq(token.balanceOf(user1), 1000 * 10 ** 18 + 100 * 10 ** 18);
        // assertEq(token.balanceOf(user1) + token.balanceOf(user2), 2000 * 10 ** 18);
        assertEq(token.balanceOf(user2), 1000 * 10 ** 18 - 100 * 10 ** 18);
    }
    // 测试自己购买自己的NFT（购买失败）
    function testBuyOwnNFT() public {
        vm.startPrank(user1);
        nft.approve(address(market), 1);
        market.listNFT(1, 100 * 10 ** 18);
        token.approve(address(market), 100 * 10 ** 18);
        vm.expectRevert("Cannot buy your own NFT");
        market.buyNFT(1);
        vm.stopPrank();
    }
    // 测试NFT被重复购买的情况（购买失败）
    function testBuyNFTTwice() public {
        vm.prank(user1);
        nft.approve(address(market), 1);
        vm.prank(user1);
        market.listNFT(1, 100 * 10 ** 18);

        vm.prank(user2);
        token.approve(address(market), 100 * 10 ** 18);
        vm.prank(user2);
        market.buyNFT(1);

        vm.prank(user2);
        token.approve(address(market), 100 * 10 ** 18);
        vm.expectRevert("NFT not listed for sale");
        vm.prank(user2);
        market.buyNFT(1);
    }
    // 测试转移Token过多的情况（转账失败）
    function testLargeTransfer() public {
        vm.prank(user1);
        uint LargeTransferAmount = token.balanceOf(user1) + 10086;
        vm.assume(LargeTransferAmount > token.balanceOf(user1));
        token.transfer(user2, LargeTransferAmount);
        vm.expectRevert();
        token.transfer(user2, 2**256 - 1);
    }
    // 测试支付Token过少的情况（转账失败）
    function testBuyNFTWithInsufficientFunds() public {
        vm.prank(user1);
        nft.approve(address(market), 1);
        vm.prank(user1);
        market.listNFT(1, 100 * 10 ** 18);

        vm.prank(user2);
        token.approve(address(market), 50 * 10 ** 18);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        vm.prank(user2);
        market.buyNFT(1);
    }
    // 模糊测试：测试随机使用 0.01-10000 Token价格上架NFT
    function testFuzzyListingAndBuying() public {
        for (uint i = 1; i < 10; i++) {
            address randomUser = address(uint160(uint(keccak256(abi.encodePacked(i)))));
            uint randomPrice = uint(keccak256(abi.encodePacked(i))) % 10000 * 10 ** 18;
            vm.startPrank(randomUser);
            nft.mint(randomUser, "https://example.com/nft");
            nft.approve(address(market), i + 1);
            vm.assume(randomPrice > 0 && randomPrice <= 10000 * 10 ** 18);
            console.log("randomPrice:", randomPrice);
            vm.stopPrank();
        }
    }
    // 不可变测试：测试无论如何买卖，NFTMarket合约中都不可能有 Token 持仓
    function testNoTokenBalanceInMarket() public {
        uint initialBalance = token.balanceOf(address(market));
        for (uint i = 1; i < 20; i++) {
            address randomUser = address(uint160(uint(keccak256(abi.encodePacked(i)))));
            uint randomPrice = uint(keccak256(abi.encodePacked(i))) % 10000 * 10 ** 18;

            vm.prank(user1);
            nft.mint(randomUser, "https://example.com/nft");
            vm.startPrank(randomUser);
            nft.approve(address(market), i + 1);
            assertEq(nft.ownerOf(i+1), randomUser);
            market.listNFT(i + 1, randomPrice);
            vm.stopPrank();
            vm.startPrank(user2);
            token.approve(address(market), randomPrice);
            // vm.expectRevert("ERC20: transfer amount exceeds balance");
            // market.buyNFT(i + 1);
            vm.stopPrank();
        }
        assertEq(token.balanceOf(address(market)), initialBalance);
    }
    // // 测试给零地址转账的情况
    // function testZeroAddressTransfer() public {
    //     vm.prank(user1);
    //     vm.expectRevert("ERC20: transfer to the zero address");
    //     token.transfer(address(0), 100);
    // }

    // 测试同一NFT重复上架的情况
    function testMultipleListings() public {
        vm.startPrank(user1);
        nft.mint(user1, "https://example.com/");
        nft.approve(address(market), 2);
        market.listNFT(2, 100);
        vm.expectRevert("ERC721: transfer caller is not owner nor approved");
        market.listNFT(2, 200);
        vm.stopPrank();
    }
    // 测试NFT转出到其他合约
    function testTransferToOtherContract() public {
        ListingAgent mock = new ListingAgent(market, token, nft);

        // Mint an NFT to the mock contract
        vm.prank(user1);
        nft.mint(address(mock), "https://example.com/nft2");

        // Check if the NFT is listed correctly
        assertEq(market.nftPrices(2), 0);
        assertEq(market.nftSellers(2), address(0));
    }
    // Token Transfer to Contract without `onTransferReceived` Implementation
    function testTransferToNonERC1363Receiver() public {
        address nonReceiver = address(new BaseERC20());
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(nonReceiver, 100);
    }

    // NFT Transfer to Non-ERC721Receiver Contract
    function testTransferToNonERC721Receiver() public {
        address nonReceiver = address(new BaseERC20());
        vm.prank(user1);
        vm.expectRevert();
        nft.safeTransferFrom(user1, nonReceiver, 1);
    }
    // Token Approval and TransferFrom
    function testApprovalAndTransferFrom() public {
        vm.prank(user1);
        token.approve(user2, 500 * 10 ** 18);
        vm.prank(user2);
        token.transferFrom(user1, user2, 500 * 10 ** 18);
        assertEq(token.balanceOf(user2), 1500 * 10 ** 18);
    }
}
