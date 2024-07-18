// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20withHook.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarket is ITokenReceiver {
    ERC20WithCallback public token;
    IERC721 public nft;
    mapping(uint256 => uint256) public nftPrices;

    constructor(address tokenAddress, address nftAddress) {
        token = ERC20WithCallback(tokenAddress);
        nft = IERC721(nftAddress);
    }

    function setNFTPrice(uint256 nftId, uint256 price) external {
        require(nft.ownerOf(nftId) == msg.sender, "Only owner can set price");
        nftPrices[nftId] = price;
    }

    function tokensReceived(address from, uint256 amount) external override {
        require(msg.sender == address(token), "Only token contract can call this function");
        uint256 nftId = getNFTIdForAmount();
        require(nftPrices[nftId] == amount, "Incorrect amount for NFT");
        nft.transferFrom(address(this), from, nftId);
    }

    function getNFTIdForAmount() internal pure returns (uint256) {
        return 1;
    }
}
