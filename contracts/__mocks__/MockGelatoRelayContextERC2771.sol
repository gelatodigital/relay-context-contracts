// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {GelatoRelayContextERC2771} from "../GelatoRelayContextERC2771.sol";

contract MockGelatoRelayContextERC2771 is GelatoRelayContextERC2771 {
    event LogMsgData(bytes data);
    event LogContext(
        address feeCollector,
        address feeToken,
        uint256 fee,
        address _msgSender
    );

    constructor(address _trustedForwarder)
        GelatoRelayContextERC2771(_trustedForwarder)
    {} // solhint-disable-line no-empty-blocks

    function emitContext() external {
        emit LogMsgData(_msgData());
        emit LogContext(
            _getFeeCollector(),
            _getFeeToken(),
            _getFee(),
            _msgSender()
        );
    }

    function testTransferRelayFee() external {
        _transferRelayFee();
    }

    function testTransferRelayFeeCapped(uint256 _maxFee) external {
        _transferRelayFeeCapped(_maxFee);
    }

    // solhint-disable-next-line no-empty-blocks
    function testOnlyGelatoRelay() external onlyGelatoRelayERC2771 {}
}
