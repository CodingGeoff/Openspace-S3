import { createPublicClient, http, parseAbi  } from 'viem';
import { mainnet } from 'viem/chains';

const client = createPublicClient({
  chain: mainnet,
  transport: http(),
});

const abi = parseAbi([
  'function ownerOf(uint256 tokenId) view returns (address)',
  'function tokenURI(uint256 tokenId) view returns (string)',
]);

async function readNFTData(tokenId:bigint) {
  const ownerAddress = await client.readContract({
    address: '0x0483b0dfc6c78062b9e999a82ffb795925381415',
    abi,
    functionName: 'ownerOf',
    args: [tokenId],
  });

  const tokenUri = await client.readContract({
    address: '0x0483b0dfc6c78062b9e999a82ffb795925381415',
    abi,
    functionName: 'tokenURI',
    args: [tokenId],
  });

  console.log(`Owner Address: ${ownerAddress}`);
  console.log(`Token URI: ${tokenUri}`);
}

// 获取第一个JSON文件
readNFTData(BigInt(1));
