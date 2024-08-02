// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC2612_Permit.sol";
import "forge-std/console.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./GeoNFT.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarket_Permit is Ownable(msg.sender), EIP712("NFTMarket_Permit", "1") {

    address public constant ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint256 public constant FEE_BASIS_POINTS = 30; // 0.3%
    address public whitelistSigner;
    address public feeRecipient;
    mapping(bytes32 => Listing) public listings;
    mapping(address => mapping(uint256 => bytes32)) private lastListingIds;
    GeoToken public geoToken;
    GeoNFT public nft;
    constructor(GeoToken _geoToken, GeoNFT _nft){
        geoToken = _geoToken;
        nft = _nft;
    }
    struct Listing {
        address seller;
        GeoNFT nft;
        uint256 tokenId;
        address paymentToken;
        uint256 price;
        uint256 expiry;
    }

    function getListing(uint256 tokenId) external view returns (bytes32) {
        bytes32 id = lastListingIds[address(nft)][tokenId];
        return listings[id].seller == address(0) ? bytes32(0x00) : id;
    }

    function createListing(uint256 tokenId, address paymentToken, uint256 price, uint256 expiry) external {
        require(expiry > block.timestamp, "Listing expired");
        require(price > 0, "Price must be greater than zero");
        require(paymentToken == address(0) || geoToken.totalSupply() > 0, "Invalid payment token");

        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(
            nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)),
            "Not approved"
        );

        Listing memory newListing = Listing({
            seller: msg.sender,
            nft: nft,
            tokenId: tokenId,
            paymentToken: paymentToken,
            price: price,
            expiry: expiry
        });

        bytes32 listingId = keccak256(abi.encode(newListing));
        require(listings[listingId].seller == address(0), "Already listed");
        listings[listingId] = newListing;
        lastListingIds[address(nft)][tokenId] = listingId;

        emit ListingCreated(address(nft), tokenId, listingId, msg.sender, paymentToken, price, expiry);
    }

    function cancelListing(bytes32 listingId) external {
        address seller = listings[listingId].seller;
        require(seller != address(0), "Listing not found");
        require(seller == msg.sender, "Only seller can cancel");
        delete listings[listingId];
        emit ListingCancelled(listingId);
    }

    function purchase(bytes32 listingId) public payable {
        _executePurchase(listingId, feeRecipient);
    }

    function purchaseWithWhitelist(bytes32 listingId, bytes calldata whitelistSignature) external payable {
        _verifyWhitelist(whitelistSignature);
        _executePurchase(listingId, address(0));
    }

    function _executePurchase(bytes32 listingId, address feeReceiver) private {
        Listing memory listing = listings[listingId];
        require(listing.seller != address(0), "Listing not found");
        require(listing.expiry > block.timestamp, "Listing expired");

        delete listings[listingId];
        listing.nft.safeTransferFrom(listing.seller, msg.sender, listing.tokenId);

        uint256 fee = feeReceiver == address(0) ? 0 : listing.price * FEE_BASIS_POINTS / 10000;
        if (listing.paymentToken == ETH_ADDRESS) {
            require(msg.value == listing.price, "Incorrect ETH value");
        } else {
            require(msg.value == 0, "Incorrect ETH value");
        }
        _transferFunds(listing.paymentToken, listing.seller, listing.price - fee);
        if (fee > 0) _transferFunds(listing.paymentToken, feeReceiver, fee);

        emit ListingSold(listingId, msg.sender, fee);
    }

    function _transferFunds(address token, address to, uint256 amount) private {
        if (token == ETH_ADDRESS) {
            (bool success,) = to.call{value: amount}("");
            require(success, "Transfer failed");
        } else {
            SafeERC20.safeTransferFrom(geoToken, msg.sender, to, amount);
        }
    }

    bytes32 constant WHITELIST_TYPEHASH = keccak256("Whitelist(address user)");

    function _verifyWhitelist(bytes calldata signature) private view {
        bytes32 hash = _hashTypedDataV4(keccak256(abi.encode(WHITELIST_TYPEHASH, msg.sender)));
        address signer = ECDSA.recover(hash, signature);
        require(signer == whitelistSigner, "Not whitelisted");
    }

    function setWhitelistSigner(address signer) external onlyOwner {
        require(signer != address(0), "Invalid address");
        require(whitelistSigner != signer, "Already set");
        whitelistSigner = signer;
        emit WhitelistSignerSet(signer);
    }

    function setFeeRecipient(address recipient) external onlyOwner {
        require(feeRecipient != recipient, "Already set");
        feeRecipient = recipient;
        emit FeeRecipientSet(recipient);
    }

    event ListingCreated(
        address indexed nft,
        uint256 indexed tokenId,
        bytes32 listingId,
        address seller,
        address paymentToken,
        uint256 price,
        uint256 expiry
    );
    event ListingCancelled(bytes32 listingId);
    event ListingSold(bytes32 listingId, address buyer, uint256 fee);
    event FeeRecipientSet(address recipient);
    event WhitelistSignerSet(address signer);
}
