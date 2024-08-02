// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./ERC2612_Permit.sol";
import "forge-std/console.sol";

contract DepositBank_Permit {
    GeoToken public geoToken;
    uint256 public constant TotalSupply = 5000000 * 10**18;
    mapping(address => uint256) public userbalance;

    constructor(GeoToken geoToken_) public payable {
        geoToken = geoToken_;
    }

    function permitdeposit(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(amount > 0, "Cannot deposit 0");
        geoToken.permitDeposit(msg.sender, address(this), amount, deadline, v, r, s);
        userbalance[msg.sender] += amount;
        geoToken.transferFrom(msg.sender, address(this), amount);
        console.log("-------------------------!!! user deposit !!!----------------------------");
        console.log("Deposit amount:", amount);
        console.log("-----------------------------------------------------------");
    }
}
