import hre = require("hardhat");
import { expect } from "chai";
import {
  MockGelato,
  MockRelay,
  MockGelatoRelayFeeCollectorERC2771,
  MockERC20,
} from "../typechain";

import {
  MessageFeeCollectorStruct,
  ExecWithSigsFeeCollectorStruct,
} from "../typechain/contracts/__mocks__/MockGelato";

import { CallWithERC2771Struct } from "../typechain/contracts/__mocks__/MockRelay";

import { utils } from "ethers";

const FEE_COLLECTOR = "0x3AC05161b76a35c1c28dC99Aa01BEd7B24cEA3bf";
const MSG_SENDER = "0xDA9644C2c2B6F50426EaBa9ce1B853e99f2D4fCa";
const correlationId = utils.formatBytes32String("CORRELATION_ID");
const dummySig = utils.randomBytes(32);

describe("Test MockGelatoRelayFeeCollectorERC2771 Smart Contract", function () {
  let mockGelato: MockGelato;
  let mockRelay: MockRelay;
  let mockRelayFeeCollectorERC2771: MockGelatoRelayFeeCollectorERC2771;
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
    mockRelayFeeCollectorERC2771 = await hre.ethers.getContract(
      "MockGelatoRelayFeeCollectorERC2771"
    );
    mockERC20 = await hre.ethers.getContract("MockERC20");

    targetAddress = mockRelayFeeCollectorERC2771.address;
    salt = 42069;
    deadline = 2664381086;
    feeToken = mockERC20.address;
  });

  it("#1: emitFeeCollector", async () => {
    const targetPayload =
      mockRelayFeeCollectorERC2771.interface.encodeFunctionData(
        "emitFeeCollector"
      );

    const callWithERC2771: CallWithERC2771Struct = {
      target: targetAddress,
      data: targetPayload,
      user: MSG_SENDER,
    };

    const relayPayload = mockRelay.interface.encodeFunctionData(
      "forwardCallERC2771",
      [callWithERC2771, false]
    );

    // build calldata
    const msg: MessageFeeCollectorStruct = {
      service: mockRelay.address,
      data: relayPayload,
      salt,
      deadline,
      feeToken,
    };

    const call: ExecWithSigsFeeCollectorStruct = {
      correlationId,
      msg,
      executorSignerSig: dummySig,
      checkerSignerSig: dummySig,
    };

    await expect(mockGelato.execWithSigsFeeCollector(call))
      .to.emit(mockRelayFeeCollectorERC2771, "LogFeeCollector")
      .withArgs(FEE_COLLECTOR);
  });

  it("#1: emitMsgSender", async () => {
    const targetPayload =
      mockRelayFeeCollectorERC2771.interface.encodeFunctionData(
        "emitMsgSender"
      );

    const callWithERC2771: CallWithERC2771Struct = {
      target: targetAddress,
      data: targetPayload,
      user: MSG_SENDER,
    };

    const relayPayload = mockRelay.interface.encodeFunctionData(
      "forwardCallERC2771",
      [callWithERC2771, false]
    );

    // build calldata
    const msg: MessageFeeCollectorStruct = {
      service: mockRelay.address,
      data: relayPayload,
      salt,
      deadline,
      feeToken,
    };

    const call: ExecWithSigsFeeCollectorStruct = {
      correlationId,
      msg,
      executorSignerSig: dummySig,
      checkerSignerSig: dummySig,
    };

    await expect(mockGelato.execWithSigsFeeCollector(call))
      .to.emit(mockRelayFeeCollectorERC2771, "LogMsgSender")
      .withArgs(MSG_SENDER);
  });

  it("#2: testOnlyGelatoRelay reverts if not GelatoRelay", async () => {
    await expect(
      mockRelayFeeCollectorERC2771.testOnlyGelatoRelay()
    ).to.be.revertedWith("GelatoRelayContext.onlyGelatoRelay");
  });
});
