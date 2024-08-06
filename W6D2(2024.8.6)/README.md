
# 多签

## 实现一个简单的多签合约

``` markdown
实现一个简单的多签合约钱包，合约包含的功能：
创建多签钱包时，确定所有的多签持有人和签名门槛
多签持有人可提交提案
其他多签人确认提案（使用交易的方式确认即可）
达到多签门槛、任何人都可以执行交易
```

- [多签合约代码](https://github.com/CodingGeoff/Openspace-S3/blob/main/W6D2(2024.8.6)/src/MultisigWallet.sol)
- [多签合约测试用例](https://github.com/CodingGeoff/Openspace-S3/blob/main/W6D2(2024.8.6)/test/MultisigWallet.t.sol)



## 实践 SafeWallet 多签钱包

``` markdown
在 Safe Wallet 支持的测试网上创建一个 2/3 多签钱包。
然后：
往多签中存入自己创建的任意 ERC20 Token。
从多签中转出一定数量的 ERC20 Token。
把 Bank 合约的管理员设置为多签。
请贴 Safe 的钱包链接。
从多签中发起， 对 Bank 的 withdraw 的调用
```

- [Safe Wallet 官网](https://app.safe.global/new-safe/create?chain=sep)
- [Safe 钱包地址](0x91F070bfDBcED03D6128036E63b2eB1238639161)


