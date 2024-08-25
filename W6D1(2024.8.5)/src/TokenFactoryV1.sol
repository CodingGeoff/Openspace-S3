// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import  "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "forge-std/console.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {erc20Token} from "./ERC20_Inscription.sol";

contract TokenFactoryV1 is UUPSUpgradeable, OwnableUpgradeable{
    event deployinscription(address tokenAddr, string symbol, uint256 totalSupply, uint256 perMint);


    function initialize(address initialOwner) initializer public {
        __Ownable_init(initialOwner);
    }




    function deployInscription(string memory symbol_, uint totalSupply_, uint perMint_) public returns (address){
        erc20Token inscription = new erc20Token();
        inscription.initialize(symbol_, totalSupply_, perMint_);
        emit deployinscription(address(inscription), symbol_, totalSupply_, perMint_);
        return address(inscription);
    }

    function mintInscription(address tokenAddr) public {
        console.log("It's free!");
        erc20Token(tokenAddr).mint(msg.sender);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}