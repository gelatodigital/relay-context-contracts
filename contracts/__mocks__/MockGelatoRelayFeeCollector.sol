// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {
    __getFeeCollector,
    GelatoRelayFeeCollector
} from "../GelatoRelayFeeCollector.sol";

contract MockGelatoRelayFeeCollector is GelatoRelayFeeCollector {
    event LogMsgData(bytes data);
    event LogFeeCollector(address feeCollector);

    function emitFeeCollector() external {
        emit LogMsgData(__msgData());
        emit LogFeeCollector(__getFeeCollector());
    }

    // solhint-disable-next-line no-empty-blocks
    function testOnlyGelatoRelay() external onlyGelatoRelay {}
}
