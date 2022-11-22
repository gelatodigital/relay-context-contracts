// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {
    GelatoRelayFeeCollectorERC2771
} from "../GelatoRelayFeeCollectorERC2771.sol";

contract MockGelatoRelayFeeCollectorERC2771 is GelatoRelayFeeCollectorERC2771 {
    event LogFeeCollector(address feeCollector);
    event LogMsgSender(address _msgSender);

    constructor(address _trustedForwarder)
        GelatoRelayFeeCollectorERC2771(_trustedForwarder)
    {} // solhint-disable-line no-empty-blocks

    function emitFeeCollector() external {
        emit LogFeeCollector(_getFeeCollector());
    }

    function emitMsgSender() external {
        emit LogMsgSender(_msgSender());
    }

    // solhint-disable-next-line no-empty-blocks
    function testOnlyGelatoRelay() external onlyGelatoRelay {}
}
