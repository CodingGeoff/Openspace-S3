// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "forge-std/console.sol";
import {erc20Token} from "./ERC20_Inscription.sol";

/// @custom:oz-upgrades-from TokenFactoryV1
contract TokenFactoryV2 is UUPSUpgradeable, OwnableUpgradeable{


    uint256 public price;
    address public erc20Addr;
    erc20Token inscription;
    uint256 public perMint;
    // address public owner;
    mapping (address => address) public tokenOwner;

    event deployinscription (address tokenAddr, string symbol, uint256 totalSupply, uint256 perMint, address owner);

    function setToken(address _erc20Addr) public {
        erc20Addr = _erc20Addr;
    }
    function deployInscription(string memory symbol_, uint256 totalSupply_, uint256 perMint_, uint256 price_) public returns (address) {
        address clone = Clones.clone(erc20Addr);
        erc20Token(clone).initialize(symbol_, totalSupply_, perMint_);
        price = price_;
        perMint = perMint_;
        // emit TokenDeployed(clone);
        tokenOwner[clone] = msg.sender;

        emit deployinscription(clone, symbol_, totalSupply_, perMint_, tokenOwner[clone]);

        return clone;
    }

    function mintInscription(address tokenAddr) public payable {
        // _mint(to, 20);
        // price = 20;
        // console.log("Sorry, there is no free lunch!");
        require(msg.value==price*perMint, "Not enough ETH balance");
        erc20Token(tokenAddr).mint(msg.sender);
        payable(tokenOwner[tokenAddr]).call{value: msg.value}("");

        console.log(tokenOwner[tokenAddr], ": I must charge you this time - ", price*perMint);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

}