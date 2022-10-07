// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoCallUtils} from "../lib/GelatoCallUtils.sol";
import {GelatoBytes} from "../lib/GelatoBytes.sol";

import {__getFeeCollector} from "../GelatoRelayFeeCollector.sol";
import {
    _getFeeCollectorRelayContext,
    GelatoRelayContext
} from "../GelatoRelayContext.sol";

import {
    _encodeFeeCollector,
    _encodeGelatoRelayContext
} from "../functions/GelatoRelayUtils.sol";

/// @dev Mock contracts for testing - UNSAFE CODE - do not copy
contract MockRelay is GelatoRelayContext {
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
                    _getFeeToken(),
                    _getFee()
                ),
                "MockRelay.forwardCall:"
            )
            : _target.revertingContractCall(
                _encodeFeeCollector(_data, __getFeeCollector()),
                "MockRelay.forwardCall:"
            );
    }
}
