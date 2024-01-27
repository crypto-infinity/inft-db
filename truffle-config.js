require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');

const { API_KEY_SEPOLIA_ALCHEMY, API_KEY_SEPOLIA_ALCHEMY_HTTPS ,API_KEY_SEPOLIA_INFURA, API_KEY_MUMBAI_ALCHEMY, API_KEY_MAINNET_ALCHEMY, MNEMONIC, ETHERSCAN_API_KEY, POLYGONSCAN_API_KEY } = process.env;

module.exports = {
  networks: {
    dev: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*"
    },
    staging: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    sepolia: {
      provider: () => new HDWalletProvider(MNEMONIC, API_KEY_SEPOLIA_ALCHEMY),
      network_id: '11155111',
      //gasPrice: 25000000000,
      skipDryRun: true,
      websocket: true,
      networkCheckTimeout: 1000000,
      timeoutBlocks: 90000
    },
    mumbai: {
      provider: () => new HDWalletProvider(MNEMONIC, API_KEY_MUMBAI_ALCHEMY),
      network_id: '80001',
      networkCheckTimeout: 1000000,
      websocket: true,
      timeoutBlocks: 90000
    },
    mainnet: {
      provider: () => new HDWalletProvider(MNEMONIC, API_KEY_MAINNET_ALCHEMY),
      network_id: '1',
      networkCheckTimeout: 1000000,
      websocket: true,
      timeoutBlocks: 90000
    }
  },
  compilers: {
    solc: {
      version: "^0.8.21",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  },
  api_keys: {
    etherscan: ETHERSCAN_API_KEY,
    polygonscan: POLYGONSCAN_API_KEY
  },
  ens: {
    enabled: true
  },
  plugins: [
    'truffle-plugin-verify'
  ]
};