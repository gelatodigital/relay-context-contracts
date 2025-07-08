// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {
    GelatoRelayFeeCollectorERC2771
} from "../GelatoRelayFeeCollectorERC2771.sol";

contract MockGelatoRelayFeeCollectorERC2771 is GelatoRelayFeeCollectorERC2771 {
    event LogFeeCollector(address feeCollector);
    event LogMsgSender(address _msgSender);

    constructor(
        address __gelatoRelayERC2771,
        address __gelatoRelayConcurrentERC2771
    )
        GelatoRelayFeeCollectorERC2771(
            __gelatoRelayERC2771,
            __gelatoRelayConcurrentERC2771
        )
    // solhint-disable-next-line no-empty-blocks
    {

    }

    function emitFeeCollector() external {
        emit LogFeeCollector(_getFeeCollector());
    }

    function emitMsgSender() external {
        emit LogMsgSender(_getMsgSender());
    }

    // solhint-disable-next-line no-empty-blocks
    function testOnlyGelatoRelayERC2771() external onlyGelatoRelayERC2771 {}
}
