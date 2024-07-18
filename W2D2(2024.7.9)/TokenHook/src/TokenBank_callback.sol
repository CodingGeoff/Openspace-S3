// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20withHook.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC777.sol";
import "@openzeppelin/contracts/interfaces/IERC777Recipient.sol";
import "@openzeppelin/contracts/interfaces/IERC777Sender.sol";
import "@openzeppelin/contracts/interfaces/IERC1820Registry.sol";

contract TokenBank is IERC777Recipient {
    ERC20WithERC777Callbacks TOKEN;
    IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    mapping(address => uint256) private _balances;

    constructor() {
        _erc1820.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    }

    function tokensReceived(
        address /* operator */,
        address from,
        address /* to */,
        uint256 amount,
        bytes calldata /* userData */,
        bytes calldata /* operatorData */
    ) external override {
        require(msg.sender == address(TOKEN), "Invalid token");
        _balances[from] += amount;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
}
