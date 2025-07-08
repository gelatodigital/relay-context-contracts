// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoRelayContextERC2771} from "../GelatoRelayContextERC2771.sol";

contract MockGelatoRelayContextERC2771 is GelatoRelayContextERC2771 {
    event LogMsgData(bytes data);
    event LogContext(
        address feeCollector,
        address feeToken,
        uint256 fee,
        address _msgSender
    );

    constructor(
        address __gelatoRelayERC2771,
        address __gelatoRelayConcurrentERC2771
    )
        GelatoRelayContextERC2771(
            __gelatoRelayERC2771,
            __gelatoRelayConcurrentERC2771
        )
    // solhint-disable-next-line no-empty-blocks
    {

    }

    function emitContext() external {
        emit LogMsgData(_getMsgData());
        emit LogContext(
            _getFeeCollector(),
            _getFeeToken(),
            _getFee(),
            _getMsgSender()
        );
    }

    function testTransferRelayFee() external {
        _transferRelayFee();
    }

    function testTransferRelayFeeCapped(uint256 _maxFee) external {
        _transferRelayFeeCapped(_maxFee);
    }

    // solhint-disable-next-line no-empty-blocks
    function testOnlyGelatoRelayERC2771() external onlyGelatoRelayERC2771 {}
}
