// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {
    RelayerContext
} from "@gelatonetwork/relayer-context/contracts/RelayerContext.sol";

contract MockRelayerContext is RelayerContext {
    event LogValues(
        bytes fnArgs,
        address feeCollector,
        address feeToken,
        uint256 fee
    );
    event LogUncheckedValues(
        address feeCollector,
        address feeToken,
        uint256 fee
    );

    constructor(address _mockRelay) RelayerContext(_mockRelay) {}

    function testUncapped() external {
        _transferFromThisToRelayerUncapped();
    }
}
