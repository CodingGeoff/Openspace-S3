
# 实现基于 Token 投票治理

``` markdown
先实现一个可以可计票的 Token
实现一个通过 DAO 管理Bank的资金使用：
Bank合约中有提取资金withdraw()，该方法仅管理员可调用。
治理 Gov 合约作为 Bank 管理员, Gov 合约使用 Token 投票来执行响应的动作。
通过发起提案从Bank合约资金，实现管理Bank的资金。
除合约代码外，需要有完成的提案、投票、执行的测试用例。
请贴出你的 github 链接。
```

- **[openzeppelin-foundry-upgrades](https://github.com/OpenZeppelin/openzeppelin-foundry-upgrades)**

- [工厂v1 合约代码](https://github.com/CodingGeoff/Openspace-S3/blob/main/W4D5(2024.7.26)/src/TokenFactoryV1.sol)
- [工厂v2 合约代码](https://github.com/CodingGeoff/Openspace-S3/blob/main/W4D5(2024.7.26)/src/TokenFactoryV2.sol)
- [Foundry 测试用例](https://github.com/CodingGeoff/Openspace-S3/blob/main/W4D5(2024.7.26)/test/TokenFactory.t.sol)
- [Foundry 测试日志](https://github.com/CodingGeoff/Openspace-S3/blob/main/W4D5(2024.7.26)/Foundry%20Test.txt)

- Token 合约：[https://sepolia.etherscan.io/address/0x046A633b40EeBB4012F9C92B9F5E1F85e376021b](https://sepolia.etherscan.io/address/0x046A633b40EeBB4012F9C92B9F5E1F85e376021b)
- TokenFactory v1 合约：
[https://sepolia.etherscan.io/address/0xd191691e9b2f8b0977f21de5be110c08d0e80e4a](https://sepolia.etherscan.io/address/0xd191691e9b2f8b0977f21de5be110c08d0e80e4a)
- TokenFactory v2 合约：[https://sepolia.etherscan.io/address/0x09233d1c40af7db3f3fb994ebfed329b011e44f2](https://sepolia.etherscan.io/address/0x09233d1c40af7db3f3fb994ebfed329b011e44f2)
- 代理合约：[https://sepolia.etherscan.io/address/0x3656dea3215733691766dcd9de7cd32fd337f2c5](https://sepolia.etherscan.io/address/0x3656dea3215733691766dcd9de7cd32fd337f2c5)
