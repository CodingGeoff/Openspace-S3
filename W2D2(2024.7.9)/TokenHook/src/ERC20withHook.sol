// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ITokenReceiver {
    function tokensReceived(address from, uint256 amount) external;
}

contract ERC20WithCallback is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function transfer (
        address sender,
        address recipient,
        uint256 amount
    ) internal  {
        super._transfer(sender, recipient, amount);
        if (recipient.code.length > 0) {
            ITokenReceiver(recipient).tokensReceived(sender, amount);
        }
    }
    function mint(address to, uint256 amount) public{
        _mint(to, amount);
    }
}
