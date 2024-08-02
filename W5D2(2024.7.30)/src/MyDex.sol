// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {UniswapV2ERC20} from "../src/UniswapV2/UniswapV2ERC20.sol";
import {UniswapV2Factory} from "../src/UniswapV2/UniswapV2Factory.sol";
import {UniswapV2Pair} from "../src/UniswapV2/UniswapV2Pair.sol";
import {UniswapV2Router01} from "../src/UniswapV2/UniswapV2Router01.sol";
import {UniswapV2Router02} from "../src/UniswapV2/UniswapV2Router02.sol";
import {UniswapV2ERC20} from "../src/UniswapV2/UniswapV2ERC20.sol";


contract MyDex {
    UniswapV2Router02 public immutable router;
    UniswapV2Factory public immutable factory;
    address public constant ETH_ADDRESS = address(0);

    constructor(address payable _routerAddress) {
        router = UniswapV2Router02(payable(_routerAddress));
        factory = UniswapV2Factory(router.factory());
    }

    // 创建交易对 (如果尚不存在)
    function createTokenPair(address tokenAddress) external {
        address pairAddress = UniswapV2Factory(router.factory()).getPair(tokenAddress, ETH_ADDRESS);
        require(pairAddress == address(0), "Pair already exists");
        factory.createPair(tokenAddress, ETH_ADDRESS);
    }

    // 添加初始化流动性
    function addLiquidity(uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address tokenAddress, uint deadline) external payable {
        address pairAddress = UniswapV2Factory(router.factory()).getPair(tokenAddress, ETH_ADDRESS);
        require(pairAddress != address(0), "Pair does not exist");

        router.addLiquidityETH{value: msg.value}(
            tokenAddress,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            msg.sender,
            deadline
        );
    }

    // 移除流动性
    function removeLiquidity(uint liquidity, uint amountTokenMin, uint amountETHMin, address tokenAddress, uint deadline) external {
        address pairAddress = UniswapV2Factory(router.factory()).getPair(tokenAddress, ETH_ADDRESS);
        require(liquidity > 0, "Liquidity amount must be greater than zero");

        router.removeLiquidityETH(
            tokenAddress,
            liquidity,
            amountTokenMin,
            amountETHMin,
            msg.sender,
            deadline
        );
    }

    // 实现代币间的相互兑换
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external {
        router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );
    }

    // 实现ETH购买ERC20代币
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable {
        router.swapETHForExactTokens(
            amountOut,
            path,
            to,
            deadline
        );
    }

    // 接收以太币
    receive() external payable {}

    // 提供一个简单的ETH提款功能
    function withdrawETH(address payable to, uint amount) external {
        require(msg.sender == to, "Only the recipient can withdraw");
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed.");
    }
}