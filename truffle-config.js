const HDWalletProvider = require('@truffle/hdwallet-provider')
const dotenv = require('dotenv')

// load env variables
dotenv.config()

const { INFURA_API_URL, MNEMONIC, ETHERSCAN_API_KEY } = process.env

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      network_id: '*',
    },
    goerli: {
      provider: () => new HDWalletProvider(MNEMONIC, INFURA_API_URL),
      network_id: 5,
      confirmations: 1,
      gas: 5500000,
      networkCheckTimeoutnetworkCheckTimeout: 10000,
      timeoutBlocks: 150,
      skipDryRun: true,
    },
  },
  // Configure your compilers
  compilers: {
    solc: {
      version: '0.8.15',
      settings: {
        optimizer: {
          enabled: true,
          runs: 100,
        },
        viaIR: true,
      },
    },
  },
  plugins: ['truffle-plugin-verify', 'truffle-contract-size'],
  api_keys: {
    etherscan: ETHERSCAN_API_KEY,
  },
}
