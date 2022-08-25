import { HardhatUserConfig } from "hardhat/config";

// PLUGINS
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "@typechain/hardhat";
import "hardhat-deploy";

const config: HardhatUserConfig = {
  // hardhat-deploy
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  solidity: "0.8.1",
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
};

export default config;
