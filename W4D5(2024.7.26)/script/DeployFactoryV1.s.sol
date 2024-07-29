// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import "../src/ERC20_Inscription.sol";
import "../src/TokenFactoryV1.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "forge-std/Script.sol";

contract DeployFactoryV1 is Script {
    function run() public {

        // address _implementation = 0x046A633b40EeBB4012F9C92B9F5E1F85e376021b; // Replace with your token address

        vm.startBroadcast();
        TokenFactoryV1 tokenFactoryv1 = new TokenFactoryV1();

        // // Encode the initializer function call
        // bytes memory data = abi.encodeWithSelector(
        //     tokenFactoryv1.deployInscription.selector,
        //     "GEI", 20000 * 10 ** 18, 2000// Initial owner/admin of the contract
        // );

        // Deploy the proxy contract with the implementation address and initializer
        ERC1967Proxy proxy = new ERC1967Proxy(address(tokenFactoryv1), "");

        vm.stopBroadcast();
        // Log the proxy address
        console.log("UUPS Proxy Address:", address(proxy));
    }
}