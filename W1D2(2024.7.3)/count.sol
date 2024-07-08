// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    uint256 public counter;

    // 获取 counter 的值
    function get() public view returns (uint256) {
        return counter;
    }

    // 给 counter 加上 x
    function add(uint256 x) public payable {
        counter += x;
    }
}
