// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Bank is Ownable {
    uint256 public totalFunds;
    address public payee;
    bool public isReleased;

    constructor() payable {
        totalFunds = msg.value;
        isReleased = false;
    }

    function withdraw() public onlyOwner {
        isReleased = true;
        payable(payee).transfer(totalFunds);
    }
}