// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/SmartBank.sol";

contract DeploySmartBank is Script {
    function run() external {
        vm.startBroadcast();
        new SmartBank();
        vm.stopBroadcast();
    }
}
