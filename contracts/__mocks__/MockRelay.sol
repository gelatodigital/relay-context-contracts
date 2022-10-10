// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoCallUtils} from "../lib/GelatoCallUtils.sol";
import {GelatoBytes} from "../lib/GelatoBytes.sol";
import {
    _getFeeCollectorRelayContext,
    _getFeeTokenRelayContext,
    _getFeeRelayContext
} from "../GelatoRelayContext.sol";
import {__getFeeCollector} from "../GelatoRelayFeeCollector.sol";
import {
    _encodeFeeCollector,
    _encodeGelatoRelayContext
} from "../functions/GelatoRelayUtils.sol";

/// @dev Mock contracts for testing - UNSAFE CODE - do not copy
contract MockRelay {
    using GelatoCallUtils for address;
    using GelatoBytes for bytes;

    function forwardCall(
        address _target,
        bytes calldata _data,
        bool _relayContext
    ) external {
        _relayContext
            ? _target.revertingContractCall(
                _encodeGelatoRelayContext(
                    _data,
                    _getFeeCollectorRelayContext(),
                    _getFeeTokenRelayContext(),
                    _getFeeRelayContext()
                ),
                "MockRelay.forwardCall:"
            )
            : _target.revertingContractCall(
                _encodeFeeCollector(_data, __getFeeCollector()),
                "MockRelay.forwardCall:"
            );
    }
}
