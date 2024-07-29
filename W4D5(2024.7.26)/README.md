
# 实现可升级合约及最小代理

``` markdown
实现一个可升级的工厂合约，工厂合约有两个方法：
1. deployInscription(string symbol, uint totalSupply, uint perMint) ，该方法用来创建 ERC20 token，（模拟铭文的 deploy）， symbol 表示 Token 的名称，totalSupply 表示可发行的数量，perMint 用来控制每次发行的数量，用于控制mintInscription函数每次发行的数量
2. mintInscription(address tokenAddr) 用来发行 ERC20 token，每次调用一次，发行perMint指定的数量。
要求：
• 合约的第一版本用普通的 new 的方式发行 ERC20 token 。
• 第二版本，deployInscription 加入一个价格参数 price  deployInscription(string symbol, uint totalSupply, uint perMint, uint price) , price 表示发行每个 token 需要支付的费用，并且 第二版本使用最小代理的方式以更节约 gas 的方式来创建 ERC20 token，需要同时修改 mintInscription 的实现以便收取每次发行的费用。
需要部署到测试网，并开源到区块链浏览器，在你的Github的 Readme.md 中备注代理合约及两个实现的合约地址。
1. 有升级的测试用例（在升级前后状态不变）
2. 有运行测试的日志或截图
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
