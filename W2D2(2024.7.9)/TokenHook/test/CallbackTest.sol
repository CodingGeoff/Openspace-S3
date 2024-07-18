// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ERC20withHook.sol";
import "../src/TokenBank_callback.sol";
import "../src/NFTMarket_callback.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestNFT is ERC721 {
    constructor() ERC721("TestNFT", "TNFT") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract ERC20WithCallbackTest is Test {
    ERC20WithCallback token;
    TokenBank tokenBank;
    NFTMarket nftMarket;
    TestNFT testNFT;
    address owner;
    address addr1;
    address addr2;

    function setUp() public {
        owner = address(this);
        addr1 = address(0x1);
        addr2 = address(0x2);

        // Deploy ERC20WithCallback
        token = new ERC20WithCallback("TestToken", "TTK");
        token.mint(owner, 1000);
        token.mint(addr1, 1000);

        // Deploy TokenBank
        tokenBank = new TokenBank(address(token));

        // Deploy TestNFT
        testNFT = new TestNFT();
        testNFT.mint(owner, 1);

        // Deploy NFTMarket
        nftMarket = new NFTMarket(address(token), address(testNFT));
        testNFT.approve(address(nftMarket), 1);
    }

    function testDepositTokens() public {
        token.transfer(address(tokenBank), 100);
    }

    function testWithdrawTokens() public {
        token.transfer(address(tokenBank), 100);
        vm.expectRevert();
        tokenBank.withdraw(50);
    }

    function testBuyNFT() public {
        nftMarket.setNFTPrice(1, 200);
        token.transfer(address(nftMarket), 200);
        assertEq(testNFT.ownerOf(1), address(this));
    }
}
