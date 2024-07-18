// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20withHook.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC777.sol";
import "@openzeppelin/contracts/interfaces/IERC777Recipient.sol";
import "@openzeppelin/contracts/interfaces/IERC777Sender.sol";
import "@openzeppelin/contracts/interfaces/IERC1820Registry.sol";


contract NFTMarketplace is IERC777Recipient {
    IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
    ERC20WithERC777Callbacks TOKEN;

    mapping(uint256 => address) private _nftOwners;
    mapping(uint256 => uint256) private _nftPrices;
    IERC721 private _nftContract;

    constructor(address nftContractAddress) {
        _erc1820.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
        _nftContract = IERC721(nftContractAddress);
    }

    function listNFT(uint256 nftId, uint256 price) external {
        require(_nftContract.ownerOf(nftId) == msg.sender, "Not the owner");
        _nftOwners[nftId] = msg.sender;
        _nftPrices[nftId] = price;
    }

    function tokensReceived(
        address /* operator */,
        address from,
        address /* to */,
        uint256 amount,
        bytes calldata userData,
        bytes calldata /* operatorData */
    ) external override {
        require(msg.sender == address(TOKEN), "Invalid token");

        uint256 nftId = abi.decode(userData, (uint256));
        require(_nftPrices[nftId] == amount, "Incorrect amount");

        address seller = _nftOwners[nftId];
        _nftOwners[nftId] = from;
        _nftPrices[nftId] = 0;

        _nftContract.safeTransferFrom(seller, from, nftId);
        ERC20WithERC777Callbacks(msg.sender).transfer(seller, amount);
    }

    function ownerOf(uint256 nftId) external view returns (address) {
        return _nftOwners[nftId];
    }
}
