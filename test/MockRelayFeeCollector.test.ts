import hre = require("hardhat");
import { expect } from "chai";
import {
  MockGelato,
  MockRelay,
  MockGelatoRelayFeeCollector,
  MockERC20,
} from "../typechain";

import {
  MessageFeeCollectorStruct,
  ExecWithSigsFeeCollectorStruct,
} from "../typechain/contracts/__mocks__/MockGelato";
import { utils } from "ethers";

const FEE_COLLECTOR = "0x3AC05161b76a35c1c28dC99Aa01BEd7B24cEA3bf";
const correlationId = utils.formatBytes32String("CORRELATION_ID");
const dummySig = utils.randomBytes(32);

describe("Test MockGelatoRelayFeeCollector Smart Contract", function () {
  let mockGelato: MockGelato;
  let mockRelay: MockRelay;
  let mockRelayFeeCollector: MockGelatoRelayFeeCollector;
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
    mockRelayFeeCollector = await hre.ethers.getContract(
      "MockGelatoRelayFeeCollector"
    );
    mockERC20 = await hre.ethers.getContract("MockERC20");

    targetAddress = mockRelayFeeCollector.address;
    salt = 42069;
    deadline = 2664381086;
    feeToken = mockERC20.address;
  });

  it("#1: emitFeeCollector", async () => {
    const targetPayload =
      mockRelayFeeCollector.interface.encodeFunctionData("emitFeeCollector");
    const relayPayload = mockRelay.interface.encodeFunctionData("forwardCall", [
      targetAddress,
      targetPayload,
      false,
    ]);

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
      .to.emit(mockRelayFeeCollector, "LogFeeCollector")
      .withArgs(FEE_COLLECTOR);
  });

  it("#2: testOnlyGelatoRelay reverts if not GelatoRelay", async () => {
    await expect(
      mockRelayFeeCollector.testOnlyGelatoRelay()
    ).to.be.revertedWith("onlyGelatoRelay");
  });
});
