// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/Vault.sol";



contract VaultScript is Script {
    function setUp() public {

    }

    function run() public {
        string memory mnemonic = "test test test test test test test test test test test junk";
        (address deployer, ) = deriveRememberKey(mnemonic, 0);
        vm.startBroadcast(deployer);


        VaultLogic logic = new VaultLogic(bytes32("0x1234"));
        Vault vault = new Vault(address(logic));
        console2.log("Vault deployed on %s", address(vault));

        vault.deposite{value: 0.1 ether}();
        vm.stopBroadcast();



    }
}