// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import "../src/ERC20_Inscription.sol";
import "../src/TokenFactoryV2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "openzeppelin-foundry-upgrades/Upgrades.sol";
import "forge-std/Script.sol";

contract DeployFactoryV2 is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        // address proxy = 0x7546C56aEfD803401Cd41BCeaDa0B8A345a53426;

        address proxy = 0x3656DeA3215733691766dcD9dE7cD32FD337F2C5;
        address tokenAddr = 0x046A633b40EeBB4012F9C92B9F5E1F85e376021b;

        Upgrades.upgradeProxy(
            proxy,
            "TokenFactoryV2.sol:TokenFactoryV2",
            abi.encodeWithSignature("setToken(address)", tokenAddr),
            deployerAddress
        );

        vm.stopBroadcast();
    }
}
