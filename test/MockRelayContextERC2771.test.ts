import hre = require("hardhat");
import { expect } from "chai";
import {
  MockGelato,
  MockRelay,
  MockGelatoRelayContextERC2771,
  MockERC20,
} from "../typechain";

import {
  MessageRelayContextStruct,
  ExecWithSigsRelayContextStruct,
} from "../typechain/contracts/__mocks__/MockGelato";

import { CallWithERC2771Struct } from "../typechain/contracts/__mocks__/MockRelay";

import { INIT_TOKEN_BALANCE as FEE } from "./constants";
import { utils } from "ethers";

const FEE_COLLECTOR = "0x3AC05161b76a35c1c28dC99Aa01BEd7B24cEA3bf";
const MSG_SENDER = "0xDA9644C2c2B6F50426EaBa9ce1B853e99f2D4fCa";
const correlationId = utils.formatBytes32String("CORRELATION_ID");
const dummySig = utils.randomBytes(32);

describe("Test MockGelatoRelayContextERC2771 Smart Contract", function () {
  let mockGelato: MockGelato;
  let mockRelay: MockRelay;
  let mockRelayContextERC2771: MockGelatoRelayContextERC2771;
  let mockERC20: MockERC20;

  let targetAddress: string;
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
    mockRelayContextERC2771 = await hre.ethers.getContract(
      "MockGelatoRelayContextERC2771"
    );
    mockERC20 = await hre.ethers.getContract("MockERC20");

    targetAddress = mockRelayContextERC2771.address;
    salt = 42069;
    deadline = 2664381086;
    feeToken = mockERC20.address;
  });

  it("#1: emitContext", async () => {
    const targetPayload =
      mockRelayContextERC2771.interface.encodeFunctionData("emitContext");

    const callWithERC2771: CallWithERC2771Struct = {
      target: targetAddress,
      data: targetPayload,
      user: MSG_SENDER,
    };

    const relayPayload = mockRelay.interface.encodeFunctionData(
      "forwardCallERC2771",
      [callWithERC2771, true]
    );

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
      .to.emit(mockRelayContextERC2771, "LogMsgData")
      .withArgs(targetPayload)
      .and.to.emit(mockRelayContextERC2771, "LogContext")
      .withArgs(FEE_COLLECTOR, feeToken, FEE, MSG_SENDER);
  });

  it("#2: testTransferRelayFee", async () => {
    const targetPayload = mockRelayContextERC2771.interface.encodeFunctionData(
      "testTransferRelayFee"
    );
    const callWithERC2771: CallWithERC2771Struct = {
      target: targetAddress,
      data: targetPayload,
      user: MSG_SENDER,
    };

    const relayPayload = mockRelay.interface.encodeFunctionData(
      "forwardCallERC2771",
      [callWithERC2771, true]
    );

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

    await mockERC20.transfer(targetAddress, FEE);

    await mockGelato.execWithSigsRelayContext(call);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#3: testTransferRelayFeeCapped: works if at maxFee", async () => {
    const maxFee = FEE;
    const targetPayload = mockRelayContextERC2771.interface.encodeFunctionData(
      "testTransferRelayFeeCapped",
      [maxFee]
    );

    const callWithERC2771: CallWithERC2771Struct = {
      target: targetAddress,
      data: targetPayload,
      user: MSG_SENDER,
    };

    const relayPayload = mockRelay.interface.encodeFunctionData(
      "forwardCallERC2771",
      [callWithERC2771, true]
    );

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

    await mockERC20.transfer(targetAddress, FEE);

    await mockGelato.execWithSigsRelayContext(call);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#4: testTransferRelayFeeCapped: works if below maxFee", async () => {
    const maxFee = FEE.add(1);
    const targetPayload = mockRelayContextERC2771.interface.encodeFunctionData(
      "testTransferRelayFeeCapped",
      [maxFee]
    );

    const callWithERC2771: CallWithERC2771Struct = {
      target: targetAddress,
      data: targetPayload,
      user: MSG_SENDER,
    };

    const relayPayload = mockRelay.interface.encodeFunctionData(
      "forwardCallERC2771",
      [callWithERC2771, true]
    );

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

    await mockERC20.transfer(targetAddress, FEE);

    await mockGelato.execWithSigsRelayContext(call);

    expect(await mockERC20.balanceOf(FEE_COLLECTOR)).to.be.eq(FEE);
  });

  it("#5: testTransferRelayFeeCapped: reverts if above maxFee", async () => {
    const maxFee = FEE.sub(1);
    const targetPayload = mockRelayContextERC2771.interface.encodeFunctionData(
      "testTransferRelayFeeCapped",
      [maxFee]
    );
    const callWithERC2771: CallWithERC2771Struct = {
      target: targetAddress,
      data: targetPayload,
      user: MSG_SENDER,
    };

    const relayPayload = mockRelay.interface.encodeFunctionData(
      "forwardCallERC2771",
      [callWithERC2771, true]
    );

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

    await mockERC20.transfer(targetAddress, FEE);

    await expect(mockGelato.execWithSigsRelayContext(call)).to.be.revertedWith(
      "ExecWithSigsFacet.execWithSigsRelayContext:MockRelay.forwardCallERC2771.withRelayContext:GelatoRelayContextERC2771._transferRelayFeeCapped: maxFee"
    );
  });

  it("#6: testOnlyGelatoRelay reverts if not GelatoRelay", async () => {
    await expect(
      mockRelayContextERC2771.testOnlyGelatoRelay()
    ).to.be.revertedWith("onlyGelatoRelay");
  });
});
