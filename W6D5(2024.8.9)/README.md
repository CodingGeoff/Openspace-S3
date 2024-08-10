
# 基于第三方服务实现合约自动化调用

``` markdown
先实现一个 Bank 合约， 用户可以通过 deposit() 存款 
然后使用 ChainLink Automation 、Gelato 或 OpenZepplin Defender Action 实现一个自动化任务
自动化任务实现：当 Bank 合约的存款超过 x (可自定义数量)时， 转移一半的存款到指定的地址（如 Owner）。
```
- [Github: https://github.com/CodingGeoff/Openspace-S3/blob/main/W6D5(2024.8.9)/src/SmartBank.sol](https://github.com/CodingGeoff/Openspace-S3/blob/main/W6D5(2024.8.9)/src/SmartBank.sol)
- [ChainLink Automation 执行链接: https://automation.chain.link/sepolia/47803540271585828170705383363227119244887746057268491185241714420655771008272](https://automation.chain.link/sepolia/47803540271585828170705383363227119244887746057268491185241714420655771008272)

