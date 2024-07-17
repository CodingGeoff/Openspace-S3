import {
  createPublicClient,
  http,
  parseAbiItem,
  decodeAbiParameters,
  parseAbiParameters
} from 'viem';
import { mainnet } from 'viem/chains';
export const publicClient = createPublicClient({
  chain: mainnet,
  transport: http()
  // 更换自己的rpc节点，此处省略
});
const USDC_CONTRACT_ADDRESS = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';

async function viewRecentTransaction() {
  const startBlock = await publicClient.getBlockNumber();
  // const recentBlock = startBlock - BigInt(100);
  const filter = await publicClient.createEventFilter({
    address: USDC_CONTRACT_ADDRESS,
    event: parseAbiItem(
      'event Transfer(address indexed, address indexed, uint256)'
    ),
    strict: true,
    fromBlock: startBlock
    // toBlock: recentBlock
  });
  const logs = await publicClient.getFilterLogs({ filter });
  // 解析并输出转账记录
  logs.forEach(log => {
    // const from = '0x' + log.topics[1];
    // const to = '0x' + log.topics[2];
    const value = parseInt(log.data, 16) / 1e6; // USDC 有 6 位小数
    //     parseAbiParameters("uint y"),
    //   [BigInt(log.data)]
    // )
    // const data_abi = "0x" + log.topics[1] + log.topics[2] + encode_amount;
    const value_from = decodeAbiParameters(
      parseAbiParameters('address indexed'),
      log.topics[1],
    );
    const value_to = decodeAbiParameters(
      parseAbiParameters('address indexed'),
      log.topics[2],
    );
    const transactionHash = log.transactionHash;
    console.log(
      `从 ${value_from} 转账给 ${value_to} ${value} USDC ,交易ID：${transactionHash}`
    );
  });
}
viewRecentTransaction();
