import hre = require("hardhat");
import { expect } from "chai";
import { MockRelay, MockGelatoRelayContext, MockERC20 } from "../typechain";
import { INIT_TOKEN_BALANCE as FEE } from "./constants";
import { ethers } from "hardhat";

const FEE_COLLECTOR = "0x3AC05161b76a35c1c28dC99Aa01BEd7B24cEA3bf";

describe("Test MockGelatoRelayContext Smart Contract", function () {
  let mockRelay: MockRelay;
  let mockRelayContext: MockGelatoRelayContext;
  let mockERC20: MockERC20;

  let target: string;
  let feeToken: string;

  beforeEach("tests", async function () {
    if (hre.network.name !== "hardhat") {
      console.error("Test Suite is meant to be run on hardhat only");
      process.exit(1);
    }

    await hre.deployments.fixture();

    mockRelay = await hre.ethers.getContract("MockRelay");
    mockRelayContext = await hre.ethers.getContract("MockGelatoRelayContext");
    mockERC20 = await hre.ethers.getContract("MockERC20");

    target = mockRelayContext.address;
    feeToken = mockERC20.address;
  });

  it("#1: emitContext", async () => {
    const data = mockRelayContext.interface.encodeFunctionData("emitContext");

    // Mimicking diamond encoding
    const encodedContextData = new ethers.utils.AbiCoder().encode(
      ["address", "address", "uint256"],
      [FEE_COLLECTOR, feeToken, FEE]
    );
    const encodedData = ethers.utils.solidityPack(
      ["bytes", "bytes"],
      [data, encodedContextData]
    );

    await expect(mockRelay.forwardCall(target, encodedData))
      .to.emit(mockRelayContext, "LogEntireMsgData")
      .withArgs(encodedData)
      .and.to.emit(mockRelayContext, "LogMsgData")
      .withArgs(data)
      .and.to.emit(mockRelayContext, "LogContext")
      .withArgs(FEE_COLLECTOR, feeToken, FEE);
  });

  it("#2: testTransferRelayFee", async () => {
    const data = mockRelayContext.interface.encodeFunctionData(
      "testTransferRelayFee"
    );

    await mockERC20.transfer(target, FEE);

    // Mimicking diamond encoding
    const encodedContextData = new ethers.utils.AbiCoder().encode(
      ["address", "address", "uint256"],
      [FEE_COLLECTOR, feeToken, FEE]
    );

    const encodedData = ethers.utils.solidityPack(
      ["bytes", "bytes"],
      [data, encodedContextData]
    );

    await mockRelay.forwardCall(target, encodedData);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#3: testTransferRelayFeeCapped: works if at maxFee", async () => {
    const maxFee = FEE;

    const data = mockRelayContext.interface.encodeFunctionData(
      "testTransferRelayFeeCapped",
      [maxFee]
    );

    await mockERC20.transfer(target, FEE);

    // Mimicking diamond encoding
    const encodedContextData = new ethers.utils.AbiCoder().encode(
      ["address", "address", "uint256"],
      [FEE_COLLECTOR, feeToken, FEE]
    );

    const encodedData = ethers.utils.solidityPack(
      ["bytes", "bytes"],
      [data, encodedContextData]
    );

    await mockRelay.forwardCall(target, encodedData);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#4: testTransferRelayFeeCapped: works if below maxFee", async () => {
    const maxFee = FEE.add(1);

    const data = mockRelayContext.interface.encodeFunctionData(
      "testTransferRelayFeeCapped",
      [maxFee]
    );

    await mockERC20.transfer(target, FEE);

    // Mimicking diamond encoding
    const encodedContextData = new ethers.utils.AbiCoder().encode(
      ["address", "address", "uint256"],
      [FEE_COLLECTOR, feeToken, FEE]
    );

    const encodedData = ethers.utils.solidityPack(
      ["bytes", "bytes"],
      [data, encodedContextData]
    );

    await mockRelay.forwardCall(target, encodedData);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#5: testTransferRelayFeeCapped: reverts if above maxFee", async () => {
    const maxFee = FEE.sub(1);

    const data = mockRelayContext.interface.encodeFunctionData(
      "testTransferRelayFeeCapped",
      [maxFee]
    );

    await mockERC20.transfer(target, FEE);

    // Mimicking diamond encoding
    const encodedContextData = new ethers.utils.AbiCoder().encode(
      ["address", "address", "uint256"],
      [FEE_COLLECTOR, feeToken, FEE]
    );

    const encodedData = ethers.utils.solidityPack(
      ["bytes", "bytes"],
      [data, encodedContextData]
    );

    await expect(mockRelay.forwardCall(target, encodedData)).to.be.revertedWith(
      "MockRelay.forwardCall:GelatoRelayContext._transferRelayFeeCapped: maxFee"
    );
  });

  it("#6: testOnlyGelatoRelay reverts if not GelatoRelay", async () => {
    await expect(mockRelayContext.testOnlyGelatoRelay()).to.be.revertedWith(
      "GelatoRelayContext.onlyGelatoRelay"
    );
  });
});
