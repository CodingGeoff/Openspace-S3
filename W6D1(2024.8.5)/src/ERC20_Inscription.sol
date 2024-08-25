// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import {Initializable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

contract erc20Token is Initializable, OwnableUpgradeable, ERC20Upgradeable{
    uint256 public perMint;

    function initialize(string memory _symbol, uint256 _totalSupply, uint256 _perMint) public initializer {
        __ERC20_init("GeoToken", _symbol);
        __Ownable_init(msg.sender);
        _mint(msg.sender, _totalSupply);
        perMint = _perMint;
    }

    function mint(address to) external {
        _mint(to, perMint);
    }
}