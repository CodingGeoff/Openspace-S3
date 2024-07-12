// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import "../src/GeoToken.sol";

contract DeployGeoToken is Script {
    function run() external {
        vm.startBroadcast();
        new GeoToken("GeoToken", "GC");
        vm.stopBroadcast();
    }
}
