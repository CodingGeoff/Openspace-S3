// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OpenspaceNFT.sol";

contract DeployOpenspaceNFT is Script {
    function run() external {
        vm.startBroadcast();
        new OpenspaceNFT();
        vm.stopBroadcast();
    }
}
