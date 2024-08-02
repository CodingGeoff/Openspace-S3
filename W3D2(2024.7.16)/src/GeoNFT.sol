// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "forge-std/console.sol";
contract GeoNFT is ERC721{
    uint256 public Tokenid;
    constructor () ERC721("GeoNFT","GC"){
    }
    function mint() public returns (uint256) {
        uint256 id = Tokenid;
        _mint(msg.sender, ++Tokenid);
        console.log("to address:", msg.sender);
        return Tokenid;
    }
}