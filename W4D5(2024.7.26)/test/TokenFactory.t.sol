// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "forge-std/console.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import "openzeppelin-foundry-upgrades/Upgrades.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {TokenFactoryV1} from "../src/TokenFactoryV1.sol";
import {TokenFactoryV2} from "../src/TokenFactoryV2.sol";

import {erc20Token} from "../src/ERC20_Inscription.sol";

contract TokenFactoryTest is Test {
    TokenFactoryV1 factory;
    TokenFactoryV2 factoryV2;
    ERC1967Proxy proxy;
    address owner;
    address newOwner;

    address tokenAddr;

    erc20Token deployedToken;
    erc20Token deployedTokenV2;

    // Set up the test environment before running tests
    function setUp() public {
        // 部署实现
        TokenFactoryV1 implementation = new TokenFactoryV1();
        // Define the owner address
        owner = vm.addr(1);
        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(address(implementation), "");
        (bool s, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature(
                "deployInscription(string,uint256,uint256)",
                "GEI",
                20000 * 10 ** 18,
                5000
            )
        );
        require(s);
        tokenAddr = abi.decode(data, (address)); // 用代理关联 MyToken 接口
        factory = TokenFactoryV1(address(proxy));
        // Define a new owner address for upgrade tests
        newOwner = address(1);
        // Emit the owner address for debugging purposes
        emit log_address(owner);
    }

    // Test the basic ERC20 functionality of the MyToken contract
    function testERC20Functionality() public {

        vm.startPrank(address(3));
        tokenAddr = factory.deployInscription("GEI", 20000 * 10 ** 18, 2000);
        deployedToken = erc20Token(tokenAddr);

        factory.mintInscription(tokenAddr);
        vm.stopPrank();
        assertEq(deployedToken.balanceOf(address(3)), 2000);
    }

    // 测试升级
    function testUpgradeability() public {
        testERC20Functionality();
        // Upgrade the proxy to a new version; MyTokenV2
        factoryV2 = new TokenFactoryV2();

        assertEq(deployedToken.balanceOf(address(3)), 2000); ///

        Upgrades.upgradeProxy(
            address(proxy),
            "TokenFactoryV2.sol:TokenFactoryV2",
            "",
            owner
        );
        ///
        (bool s1, ) = address(proxy).call(
            abi.encodeWithSignature("setToken(address)", tokenAddr)
        );
        require(s1);

        vm.deal(owner, 200000000000000000000000000000000000000 ether);
        vm.deal(address(2), 200000000000000000000000000000000000000 ether);

        vm.startPrank(address(2));

        (bool s, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature(
                "deployInscription(string,uint256,uint256,uint256)",
                "GEI",
                20000 * 10 ** 18,
                15000,
                555
            )
        );

        tokenAddr = abi.decode(data, (address));
        deployedTokenV2 = erc20Token(tokenAddr);

        assertEq(deployedTokenV2.balanceOf(address(37777777777)), 0);
        address(proxy).call{value: 555}(
            abi.encodeWithSignature("mintInscription(address)", tokenAddr)
        );

        // uint256 balance = IERC20(tokenAddr).balanceOf(address(2));

        assertEq(deployedToken.balanceOf(address(3)), 2000);

        assertEq(deployedTokenV2.balanceOf(address(2)), 15000);
        vm.stopPrank();

    }
}
