// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC777.sol";
import "@openzeppelin/contracts/interfaces/IERC777Recipient.sol";
import "@openzeppelin/contracts/interfaces/IERC777Sender.sol";
import "@openzeppelin/contracts/interfaces/IERC1820Registry.sol";


contract ERC20WithERC777Callbacks is ERC20 {
    IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    constructor(string memory name, string memory symbol) ERC20("GeoToken", "GTH") {}

    function sendCoin(address sender, address recipient, uint256 amount) internal virtual {
        super._transfer(sender, recipient, amount);

        address implementer = _erc1820.getInterfaceImplementer(recipient, TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(
                address(this),
                sender,
                recipient,
                amount,
                "",
                ""
            );
        }
    }
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
