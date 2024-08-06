// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Test.sol";
// import "forge-std/console.sol";
// import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
// import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
// import "openzeppelin-foundry-upgrades/Upgrades.sol";

// import {UniswapV2ERC20} from "../src/UniswapV2/UniswapV2ERC20.sol";
// import {UniswapV2Factory} from "../src/UniswapV2/UniswapV2Factory.sol";
// import {UniswapV2Pair} from "../src/UniswapV2/UniswapV2Pair.sol";
// import {UniswapV2Router01} from "../src/UniswapV2/UniswapV2Router01.sol";
// import {UniswapV2Router02} from "../src/UniswapV2/UniswapV2Router02.sol";
// import {UniswapV2ERC20} from "../src/UniswapV2/UniswapV2ERC20.sol";
// import {RNT} from "../src/RNT.sol";
// import {MyDex} from "../src/MyDex.sol";

// contract MyDexTest is Test {
//     UniswapV2Router02 router;
//     MyDex dex;
//     UniswapV2ERC20 token;
//     address owner;
//     address alice;
//     address bob;
//     UniswapV2Factory factory;
//     UniswapV2ERC20 WETH;
//     address factoryAddr;
//     address wethAddr;

//     // 部署 Uniswap V2 Router 和 MyDex 合约
//     function setUp() public {
//         owner = address(this);
//         alice = makeAddr("Alice");
//         bob = makeAddr("Bob");
//         factoryAddr = address(new UniswapV2Factory());
//         wethAddr = address(new UniswapV2ERC20());

//         // 假设我们已经部署了 Uniswap V2 Router 合约
//         address routerAddress = address(new UniswapV2Router02(factoryAddr, wethAddr)); // 替换为Router的地址

//         // 部署 MyDex 合约
//         dex = new MyDex(payable(address(router)));
//         token = new RNT();
//     }

//     // 测试创建交易对
//     function testCreateTokenPair() public {
//         dex.createTokenPair(address(token));
//         assertEq(address(token), UniswapV2Factory(router.factory()).getPair(address(token), wethAddr));
//     }

//     // 测试添加初始化流动性
//     function testAddLiquidity() public {
//         uint amountTokenDesired = 1000 * 10 ** 18; // 1000 tokens
//         uint amountETHDesired = 100 * 10 ** 18; // 100 ETH

//         token._mint(address(this), amountTokenDesired); // 假设token合约受信任并可以被测试合约铸造
//         vm.deal(address(this), amountETHDesired);

//         dex.addLiquidity{value: amountETHDesired}(
//             amountTokenDesired,
//             1, // amountTokenMin
//             1, // amountETHMin
//             address(token),
//             block.timestamp + 1000
//         );

//         (uint amountToken, uint amountETH, ) = dex.addLiquidity(
//             address(token),
//             amountTokenDesired,
//             amountTokenDesired,
//             1,
//             1,
//             address(this),
//             block.timestamp + 1000
//         );
//         assertEq(amountToken, amountTokenDesired);
//         assertEq(amountETH, amountETHDesired);
//     }

//     // 测试移除流动性
//     function testRemoveLiquidity() public {
//         uint amountTokenDesired = 1000 * 10 ** 18; // 1000 tokens
//         uint amountETHDesired = 100 * 10 ** 18; // 100 ETH
//          (uint amountToken, uint amountETH, ) = dex.addLiquidity(
//             address(token),
//             amountTokenDesired,
//             amountTokenDesired,
//             1,
//             1,
//             address(this),
//             block.timestamp + 1000
//         );

//         uint liquidity = 1000 * 10 ** 18; // 假设流动性份额
//         uint amountTokenMin = 1 * 10 ** 18;
//         uint amountETHMin = 10 * 10 ** 18;


//         dex.removeLiquidity(
//             address(token),
//             address(WETH),
//             liquidity,
//             amountTokenMin,
//             amountETHMin,
//             address(this),
//             block.timestamp + 1000
//         );
//         assertGt(amountToken, amountTokenMin);
//         assertGt(amountETH, amountETHMin);
//     }

//     // 测试代币间的相互兑换
//     function testSwapExactTokensForTokens() public {
//         uint amountIn = 100 * 10 ** 18; // 100 tokens
//         uint amountOutMin = 10 * 10 ** 18; // 最小接收ETH数量
//         address[] memory path = new address[](2);
//         path[0] = address(token);
//         path[1] = address(WETH); // WETH 地址

//         token._mint(address(this), amountIn); // 假设token合约受信任并可以被测试合约铸造

//         dex.swapExactTokensForTokens(
//             amountIn,
//             amountOutMin,
//             path,
//             address(this),
//             block.timestamp + 1000
//         );

//         dex.swapExactTokensForTokens(
//             amountIn,
//             amountOutMin,
//             path,
//             address(this),
//             block.timestamp + 1000
//         );
//         assertGt(amounts[0], 0);
//         assertGt(amounts[1], amountOutMin);
//     }
// }