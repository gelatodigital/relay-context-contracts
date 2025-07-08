import { deployments, getNamedAccounts } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  if (hre.network.name !== "hardhat") {
    console.error(`Only deploy Mock on hardhat`);
    process.exit(1);
  }

  const mockRelay = await deployments.get("MockRelay");

  await deploy("MockGelatoRelayFeeCollectorERC2771", {
    from: deployer,
    args: [mockRelay.address, mockRelay.address],
  });
};

func.skip = async (hre: HardhatRuntimeEnvironment) => {
  return hre.network.name !== "hardhat";
};
func.dependencies = ["MockRelay"];
func.tags = ["MockGelatoRelayFeeCollectorERC2771"];

export default func;
