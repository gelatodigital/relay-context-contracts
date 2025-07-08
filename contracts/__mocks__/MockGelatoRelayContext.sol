// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoRelayContext} from "../GelatoRelayContext.sol";

contract MockGelatoRelayContext is GelatoRelayContext {
    event LogMsgData(bytes data);
    event LogContext(address feeCollector, address feeToken, uint256 fee);

    // solhint-disable-next-line no-empty-blocks
    constructor(address __gelatoRelay) GelatoRelayContext(__gelatoRelay) {}

    function emitContext() external {
        emit LogMsgData(_getMsgData());
        emit LogContext(_getFeeCollector(), _getFeeToken(), _getFee());
    }

    function testTransferRelayFee() external {
        _transferRelayFee();
    }

    function testTransferRelayFeeCapped(uint256 _maxFee) external {
        _transferRelayFeeCapped(_maxFee);
    }

    // solhint-disable-next-line no-empty-blocks
    function testOnlyGelatoRelay() external onlyGelatoRelay {}
}
