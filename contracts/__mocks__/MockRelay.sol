// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoCallUtils} from "../lib/GelatoCallUtils.sol";
import {GelatoBytes} from "../lib/GelatoBytes.sol";
import {
    _getFeeCollectorRelayContext,
    _getFeeTokenRelayContext,
    _getFeeRelayContext
} from "../GelatoRelayContext.sol";
import {
    _getFeeCollectorRelayContextERC2771,
    _getFeeTokenRelayContextERC2771,
    _getFeeRelayContextERC2771,
    _getMsgSenderRelayContextERC2771
} from "../GelatoRelayContextERC2771.sol";
import {__getFeeCollector} from "../GelatoRelayFeeCollector.sol";
import {
    _getFeeCollectorERC2771,
    _getMsgSenderFeeCollectorERC2771
} from "../GelatoRelayFeeCollectorERC2771.sol";
import {
    _encodeFeeCollector,
    _encodeFeeCollectorERC2771,
    _encodeRelayContext,
    _encodeRelayContextERC2771
} from "../functions/GelatoRelayUtils.sol";
import {CallWithERC2771} from "../types/CallTypes.sol";

/// @dev Mock contracts for testing - UNSAFE CODE - do not copy
contract MockRelay {
    using GelatoCallUtils for address;
    using GelatoBytes for bytes;

    function forwardCall(
        address _target,
        bytes calldata _data,
        bool _isRelayContext
    ) external {
        _isRelayContext
            ? _target.revertingContractCall(
                _encodeRelayContext(
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

    function forwardCallERC2771(
        CallWithERC2771 calldata _call,
        bool _isRelayContext
    ) external {
        _isRelayContext
            ? _call.target.revertingContractCall(
                _encodeRelayContextERC2771(
                    _call.data,
                    _getFeeCollectorRelayContext(),
                    _getFeeTokenRelayContext(),
                    _getFeeRelayContext(),
                    _call.user
                ),
                "MockRelay.forwardCallERC2771.withRelayContext:"
            )
            : _call.target.revertingContractCall(
                _encodeFeeCollectorERC2771(
                    _call.data,
                    __getFeeCollector(),
                    _call.user
                ),
                "MockRelay.forwardCall.withFeeCollector:"
            );
    }
}
