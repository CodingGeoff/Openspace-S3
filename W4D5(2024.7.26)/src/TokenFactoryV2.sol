// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "forge-std/console.sol";
import {erc20Token} from "./ERC20_Inscription.sol";

/// @custom:oz-upgrades-from TokenFactoryV1
contract TokenFactoryV2 is UUPSUpgradeable {


    uint256 public price;
    address public erc20Addr;
    erc20Token inscription;

    event deployinscription (address tokenAddr, string symbol, uint256 totalSupply, uint256 perMint);

    function setToken(address _erc20Addr) public {
        erc20Addr = _erc20Addr;
    }
    function deployInscription(string memory symbol_, uint256 totalSupply_, uint256 perMint_, uint256 price_) public returns (address) {
        // erc20Token inscription = new erc20Token(_symbol, totalSupply, perMint);
        // inscription = new erc20Token();

        address clone = Clones.clone(erc20Addr);
        erc20Token(clone).initialize(symbol_, totalSupply_, perMint_);
        price = price_;
        // emit TokenDeployed(clone);

        emit deployinscription(clone, symbol_, totalSupply_, perMint_);
        return clone;
    }

    function mintInscription(address tokenAddr) public payable {
        // _mint(to, 20);
        // price = 20;
        console.log("Sorry, there is no free lunch!");
        require(msg.value==price, "Not enough ETH balance");
        erc20Token(tokenAddr).mint(msg.sender);

        console.log("I must charge you this time", price);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
    {}

}