// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoBytes} from "../lib/GelatoBytes.sol";
import {_encodeGelatoRelayContext} from "../functions/GelatoRelayUtils.sol";

/// @dev Mock contracts for testing - UNSAFE CODE - do not copy
contract MockRelay {
    using GelatoBytes for bytes;

    function forwardCall(
        address _target,
        bytes calldata _data,
        address _feeCollector,
        address _feeToken,
        uint256 _fee
    ) external {
        (bool success, bytes memory returndata) = _target.call(
            _encodeGelatoRelayContext(_data, _feeCollector, _feeToken, _fee)
        );
        if (!success) returndata.revertWithError("MockRelay.forwardCall:");
    }
}
