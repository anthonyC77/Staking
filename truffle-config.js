const path = require("path");
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

let mnemonic = 'expect time text dilemma struggle input auto coral social pledge road lunar';
let infura = 'https://rinkeby.infura.io/v3/7f1b18274af4462cbf7ad68d64362c33';

// 0x3C7d53Ee0d5D28D0e69BE6B7d93f1B99e236d919
module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    development: {
     host: "localhost",     // Localhost (default: none)
     port: 7545,            // Standard Ethereum port (default: none)
     network_id: "1000",       // Any network (default: no
   },
    kovan: {
      provider: () => new HDWalletProvider(mnemonic,infura),
      network_id:    42,       // Ropsten's id
      gas:           5500000, // Ropsten has a lower block limit than mainnet
      confirmations: 2,       // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,     // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun:    true     // Skip dry run before migrations? (default: false for public nets )
    },
     rinkeby: {
      provider: () => new HDWalletProvider(mnemonic,infura),
      network_id:    4,       // Ropsten's id
      gas:           6721975, // Ropsten has a lower block limit than mainnet
      gasPrice: 20000000000,	// <-- Use this low gas price
	  confirmations: 2,       // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,     // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun:    true     // Skip dry run before migrations? (default: false for public nets )
    },
  },
  // Set default mocha options here, use special reporters etc.
  mocha: {
  // timeout: 100000
  },
  compilers: {
    solc: {
      version: "0.8.1",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
       settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: false,
          runs: 200
        },
        evmVersion: "byzantium"
      }
    }
  },
};


