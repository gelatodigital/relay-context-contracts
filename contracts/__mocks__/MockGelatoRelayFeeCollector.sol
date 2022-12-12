// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoRelayFeeCollector} from "../GelatoRelayFeeCollector.sol";

contract MockGelatoRelayFeeCollector is GelatoRelayFeeCollector {
    event LogFeeCollector(address feeCollector);

    function emitFeeCollector() external {
        emit LogFeeCollector(_getFeeCollector());
    }

    // solhint-disable-next-line no-empty-blocks
    function testOnlyGelatoRelay() external onlyGelatoRelay {}
}
