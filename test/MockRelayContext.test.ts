import hre = require("hardhat");
import { expect } from "chai";
import {
  MockGelato,
  MockRelay,
  MockGelatoRelayContext,
  MockERC20,
} from "../typechain";

import {
  MessageRelayContextStruct,
  ExecWithSigsRelayContextStruct,
} from "../typechain/contracts/__mocks__/MockGelato";
import { INIT_TOKEN_BALANCE as FEE } from "./constants";
import { utils } from "ethers";

const FEE_COLLECTOR = "0x3AC05161b76a35c1c28dC99Aa01BEd7B24cEA3bf";
const correlationId = utils.formatBytes32String("CORRELATION_ID");
const dummySig = utils.randomBytes(32);

describe("Test MockGelatoRelayContext Smart Contract", function () {
  let mockGelato: MockGelato;
  let mockRelay: MockRelay;
  let mockRelayContext: MockGelatoRelayContext;
  let mockERC20: MockERC20;

  let targetRelayContext: string;
  let salt: number;
  let deadline: number;
  let feeToken: string;

  beforeEach("tests", async function () {
    if (hre.network.name !== "hardhat") {
      console.error("Test Suite is meant to be run on hardhat only");
      process.exit(1);
    }

    await hre.deployments.fixture();

    mockGelato = await hre.ethers.getContract("MockGelato");
    mockRelay = await hre.ethers.getContract("MockRelay");
    mockRelayContext = await hre.ethers.getContract("MockGelatoRelayContext");
    mockERC20 = await hre.ethers.getContract("MockERC20");

    targetRelayContext = mockRelayContext.address;
    salt = Date.now();
    deadline = 2664381086;
    feeToken = mockERC20.address;
  });

  it("#1: emitContext", async () => {
    const targetPayload =
      mockRelayContext.interface.encodeFunctionData("emitContext");

    const relayPayload = mockRelay.interface.encodeFunctionData("forwardCall", [
      targetRelayContext,
      targetPayload,
      true,
    ]);

    // build calldata
    const msg: MessageRelayContextStruct = {
      service: mockRelay.address,
      data: relayPayload,
      salt,
      deadline,
      feeToken,
      fee: FEE,
    };
    const call: ExecWithSigsRelayContextStruct = {
      correlationId,
      msg,
      executorSignerSig: dummySig,
      checkerSignerSig: dummySig,
    };

    await expect(mockGelato.execWithSigsRelayContext(call))
      .to.emit(mockRelayContext, "LogMsgData")
      .withArgs(targetPayload)
      .and.to.emit(mockRelayContext, "LogContext")
      .withArgs(FEE_COLLECTOR, feeToken, FEE);
  });

  it("#2: testTransferRelayFee", async () => {
    const targetPayload = mockRelayContext.interface.encodeFunctionData(
      "testTransferRelayFee"
    );
    const relayPayload = mockRelay.interface.encodeFunctionData("forwardCall", [
      targetRelayContext,
      targetPayload,
      true,
    ]);

    // build calldata
    const msg: MessageRelayContextStruct = {
      service: mockRelay.address,
      data: relayPayload,
      salt,
      deadline,
      feeToken,
      fee: FEE,
    };

    const call: ExecWithSigsRelayContextStruct = {
      correlationId,
      msg,
      executorSignerSig: dummySig,
      checkerSignerSig: dummySig,
    };

    await mockERC20.transfer(targetRelayContext, FEE);

    await mockGelato.execWithSigsRelayContext(call);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#3: testTransferRelayFeeCapped: works if at maxFee", async () => {
    const maxFee = FEE;
    const targetPayload = mockRelayContext.interface.encodeFunctionData(
      "testTransferRelayFeeCapped",
      [maxFee]
    );
    const relayPayload = mockRelay.interface.encodeFunctionData("forwardCall", [
      targetRelayContext,
      targetPayload,
      true,
    ]);

    // build calldata
    const msg: MessageRelayContextStruct = {
      service: mockRelay.address,
      data: relayPayload,
      salt,
      deadline,
      feeToken,
      fee: FEE,
    };

    const call: ExecWithSigsRelayContextStruct = {
      correlationId,
      msg,
      executorSignerSig: dummySig,
      checkerSignerSig: dummySig,
    };

    await mockERC20.transfer(targetRelayContext, FEE);

    await mockGelato.execWithSigsRelayContext(call);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#4: testTransferRelayFeeCapped: works if below maxFee", async () => {
    const maxFee = FEE.add(1);
    const targetPayload = mockRelayContext.interface.encodeFunctionData(
      "testTransferRelayFeeCapped",
      [maxFee]
    );
    const relayPayload = mockRelay.interface.encodeFunctionData("forwardCall", [
      targetRelayContext,
      targetPayload,
      true,
    ]);

    // build calldata
    const msg: MessageRelayContextStruct = {
      service: mockRelay.address,
      data: relayPayload,
      salt,
      deadline,
      feeToken,
      fee: FEE,
    };

    const call: ExecWithSigsRelayContextStruct = {
      correlationId,
      msg,
      executorSignerSig: dummySig,
      checkerSignerSig: dummySig,
    };

    await mockERC20.transfer(targetRelayContext, FEE);

    await mockGelato.execWithSigsRelayContext(call);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#5: testTransferRelayFeeCapped: reverts if above maxFee", async () => {
    const maxFee = FEE.sub(1);
    const targetPayload = mockRelayContext.interface.encodeFunctionData(
      "testTransferRelayFeeCapped",
      [maxFee]
    );
    const relayPayload = mockRelay.interface.encodeFunctionData("forwardCall", [
      targetRelayContext,
      targetPayload,
      true,
    ]);

    // build calldata
    const msg: MessageRelayContextStruct = {
      service: mockRelay.address,
      data: relayPayload,
      salt,
      deadline,
      feeToken,
      fee: FEE,
    };

    const call: ExecWithSigsRelayContextStruct = {
      correlationId,
      msg,
      executorSignerSig: dummySig,
      checkerSignerSig: dummySig,
    };

    await mockERC20.transfer(targetRelayContext, FEE);

    await expect(mockGelato.execWithSigsRelayContext(call)).to.be.revertedWith(
      "ExecWithSigsFacet.execWithSigsRelayContext:MockRelay.forwardCall:GelatoRelayContext._transferRelayFeeCapped: maxFee"
    );
  });

  it("#6: testOnlyGelatoRelay reverts if not GelatoRelay", async () => {
    await expect(mockRelayContext.testOnlyGelatoRelay()).to.be.revertedWith(
      "onlyGelatoRelay"
    );
  });
});
