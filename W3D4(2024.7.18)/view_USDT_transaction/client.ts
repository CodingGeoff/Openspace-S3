import { createClient, http } from 'viem'
import { mainnet } from 'viem/chains'

const client = createClient({
  chain: mainnet,
  transport: http()
})