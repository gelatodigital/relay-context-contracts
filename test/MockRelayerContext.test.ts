import hre = require("hardhat");
import { expect } from "chai";
//import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signers";
import { MockRelayer, MockRelayerContext, MockERC20 } from "../typechain";
import { INIT_TOKEN_BALANCE as FEE } from "./constants";
import { ethers } from "hardhat";

const FEE_COLLECTOR = "0x3CACa7b48D0573D793d3b0279b5F0029180E83b6";

describe("Test MockRelayer Smart Contract", function () {
  // let user: SignerWithAddress;

  let mockRelayer: MockRelayer;
  let mockRelayerContext: MockRelayerContext;
  let mockERC20: MockERC20;

  let target: string;
  let feeToken: string;

  beforeEach("tests", async function () {
    if (hre.network.name !== "hardhat") {
      console.error("Test Suite is meant to be run on hardhat only");
      process.exit(1);
    }

    await hre.deployments.fixture();

    //  [user] = await hre.ethers.getSigners();

    mockRelayer = await hre.ethers.getContract("MockRelayer");
    mockRelayerContext = await hre.ethers.getContract("MockRelayerContext");
    mockERC20 = await hre.ethers.getContract("MockERC20");

    target = mockRelayerContext.address;
    feeToken = mockERC20.address;
  });
  it("#0: MockRelayerContext has MockRelayer set as relayer", async () => {
    expect(await mockRelayerContext.relayer()).to.be.eq(mockRelayer.address);
  });

  it("#1: emitContext", async () => {
    const data = mockRelayerContext.interface.encodeFunctionData("emitContext");

    // Mimic RelayerUtils _encodeRelayerContext used on-chain by MockRelayer
    const encodedContextData = new ethers.utils.AbiCoder().encode(
      ["address", "address", "uint256"],
      [FEE_COLLECTOR, feeToken, FEE]
    );
    const encodedData = ethers.utils.solidityPack(
      ["bytes", "bytes"],
      [data, encodedContextData]
    );

    await expect(
      mockRelayer.forwardCall(target, data, FEE_COLLECTOR, feeToken, FEE)
    )
      .to.emit(mockRelayerContext, "LogMsgData")
      .withArgs(encodedData)
      .and.to.emit(mockRelayerContext, "LogFnArgs")
      .withArgs(data)
      .and.to.emit(mockRelayerContext, "LogContext")
      .withArgs(FEE_COLLECTOR, feeToken, FEE)
      .and.to.emit(mockRelayerContext, "LogUncheckedContext")
      .withArgs(FEE_COLLECTOR, feeToken, FEE);
  });

  it("#2: onlyRelayerTransferUncapped", async () => {
    const data = mockRelayerContext.interface.encodeFunctionData(
      "onlyRelayerTransferUncapped"
    );

    await mockERC20.transfer(target, FEE);

    await mockRelayer.forwardCall(target, data, FEE_COLLECTOR, feeToken, FEE);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#3: onlyRelayerTransferUncapped reverts if not relayer", async () => {
    await expect(
      mockRelayerContext.onlyRelayerTransferUncapped()
    ).to.be.revertedWith("RelayerContext.onlyRelayer");
  });

  it("#4: onlyRelayerTransferCapped: works if at maxFee", async () => {
    const maxFee = FEE;

    const data = mockRelayerContext.interface.encodeFunctionData(
      "onlyRelayerTransferCapped",
      [maxFee]
    );

    await mockERC20.transfer(target, FEE);

    await mockRelayer.forwardCall(target, data, FEE_COLLECTOR, feeToken, FEE);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#5: onlyRelayerTransferCapped: works if below maxFee", async () => {
    const maxFee = FEE.add(1);

    const data = mockRelayerContext.interface.encodeFunctionData(
      "onlyRelayerTransferCapped",
      [maxFee]
    );

    await mockERC20.transfer(target, FEE);

    await mockRelayer.forwardCall(target, data, FEE_COLLECTOR, feeToken, FEE);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#6: onlyRelayerTransferCapped: reverts if above maxFee", async () => {
    const maxFee = FEE.sub(1);

    const data = mockRelayerContext.interface.encodeFunctionData(
      "onlyRelayerTransferCapped",
      [maxFee]
    );

    await mockERC20.transfer(target, FEE);

    await expect(
      mockRelayer.forwardCall(target, data, FEE_COLLECTOR, feeToken, FEE)
    ).to.be.revertedWith(
      "MockRelayer.forwardCall:RelayerContext._uncheckedTransferToFeeCollectorCapped: maxFee"
    );
  });

  it("#7: onlyRelayerTransferCapped reverts if not relayer", async () => {
    await expect(
      mockRelayerContext.onlyRelayerTransferCapped(0)
    ).to.be.revertedWith("RelayerContext.onlyRelayer");
  });
});
