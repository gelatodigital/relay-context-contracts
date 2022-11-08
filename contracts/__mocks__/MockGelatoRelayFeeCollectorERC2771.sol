// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {
    GelatoRelayFeeCollectorERC2771
} from "../GelatoRelayFeeCollectorERC2771.sol";

contract MockGelatoRelayFeeCollectorERC2771 is GelatoRelayFeeCollectorERC2771 {
    event LogFeeCollector(address feeCollector);
    event LogMsgSender(address _msgSender);

    function emitFeeCollector() external {
        emit LogFeeCollector(_getFeeCollector());
    }

    function emitMsgSender() external {
        emit LogMsgSender(_getMsgSender());
    }

    // solhint-disable-next-line no-empty-blocks
    function testOnlyGelatoRelay() external onlyGelatoRelay {}
}
