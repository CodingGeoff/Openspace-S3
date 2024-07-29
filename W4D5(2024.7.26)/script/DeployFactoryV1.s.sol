// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import "../src/ERC20_Inscription.sol";
import "../src/TokenFactoryV1.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "forge-std/Script.sol";

contract DeployFactoryV1 is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        // address _implementation = 0x046A633b40EeBB4012F9C92B9F5E1F85e376021b; // Replace with your token address

        vm.startBroadcast(deployerPrivateKey);
        TokenFactoryV1 tokenFactoryv1 = new TokenFactoryV1();

        // // Encode the initializer function call
        bytes memory data = abi.encodeWithSelector(
            tokenFactoryv1.initialize.selector,
            deployerAddress     // Initial owner/admin of the contract
        );

        // Deploy the proxy contract with the implementation address and initializer
        ERC1967Proxy proxy = new ERC1967Proxy(address(tokenFactoryv1), data);

        vm.stopBroadcast();
        // Log the proxy address
        console.log("UUPS Proxy Address:", address(proxy));
    }
}