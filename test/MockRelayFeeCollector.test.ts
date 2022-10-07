// import hre = require("hardhat");
// import { expect } from "chai";
// import { MockRelay, MockGelatoRelayFeeCollector } from "../typechain";
// import { ethers } from "hardhat";

// const FEE_COLLECTOR = "0x3AC05161b76a35c1c28dC99Aa01BEd7B24cEA3bf";

// describe("Test MockGelatoRelayFeeCollector Smart Contract", function () {
//   let mockRelay: MockRelay;
//   let mockRelayFeeCollector: MockGelatoRelayFeeCollector;

//   let target: string;

//   beforeEach("tests", async function () {
//     if (hre.network.name !== "hardhat") {
//       console.error("Test Suite is meant to be run on hardhat only");
//       process.exit(1);
//     }

//     await hre.deployments.fixture();

//     mockRelay = await hre.ethers.getContract("MockRelay");
//     mockRelayFeeCollector = await hre.ethers.getContract(
//       "MockGelatoRelayFeeCollector"
//     );

//     target = mockRelayFeeCollector.address;
//   });

//   it("#1: emitFeeCollector", async () => {
//     const data =
//       mockRelayFeeCollector.interface.encodeFunctionData("emitFeeCollector");

//     // Mimicking diamond encoding
//     const encodedFeeCollector = new ethers.utils.AbiCoder().encode(
//       ["address"],
//       [FEE_COLLECTOR]
//     );

//     const encodedData = ethers.utils.solidityPack(
//       ["bytes", "bytes"],
//       [data, encodedFeeCollector]
//     );

//     await expect(mockRelay.forwardCall(target, encodedData))
//       .to.emit(mockRelayFeeCollector, "LogEntireMsgData")
//       .withArgs(encodedData)
//       .and.to.emit(mockRelayFeeCollector, "LogMsgData")
//       .withArgs(data)
//       .and.to.emit(mockRelayFeeCollector, "LogFeeCollector")
//       .withArgs(FEE_COLLECTOR);
//   });

//   it("#2: testOnlyGelatoRelay reverts if not GelatoRelay", async () => {
//     await expect(
//       mockRelayFeeCollector.testOnlyGelatoRelay()
//     ).to.be.revertedWith("GelatoRelayContext.onlyGelatoRelay");
//   });
// });
