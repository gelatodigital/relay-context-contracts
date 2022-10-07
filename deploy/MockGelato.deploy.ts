import { deployments, getNamedAccounts } from "hardhat";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  if (hre.network.name !== "hardhat") {
    console.error(`Only deploy Mock on hardhat`);
    process.exit(1);
  }

  const feeCollector = "0x3AC05161b76a35c1c28dC99Aa01BEd7B24cEA3bf";

  await deploy("MockGelato", {
    from: deployer,
    args: [feeCollector],
  });
};

func.skip = async (hre: HardhatRuntimeEnvironment) => {
  return hre.network.name !== "hardhat";
};
func.tags = ["MockGelato"];

export default func;
