// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20withHook.sol";

contract TokenBank is ITokenReceiver {
    ERC20WithCallback public token;

    mapping(address => uint256) public balances;

    constructor(address tokenAddress) {
        token = ERC20WithCallback(tokenAddress);
    }

    function tokensReceived(address from, uint256 amount) external override {
        require(msg.sender == address(token), "Only token contract can call this function");
        balances[from] += amount;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }
}
