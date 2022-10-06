// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoRelayContext} from "../GelatoRelayContext.sol";

contract MockGelatoRelayContext is GelatoRelayContext {
    event LogEntireMsgData(bytes msgData);
    event LogData(bytes data);
    event LogContext(address feeCollector, address feeToken, uint256 fee);

    function emitContext() external {
        emit LogEntireMsgData(msg.data);
        emit LogData(_msgDataRelayContext());
        (
            address feeCollector,
            address feeToken,
            uint256 fee
        ) = _getRelayContext();
        emit LogContext(feeCollector, feeToken, fee);
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
