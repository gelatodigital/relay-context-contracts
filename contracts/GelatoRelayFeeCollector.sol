// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoRelayBase} from "./base/GelatoRelayBase.sol";

uint256 constant _FEE_COLLECTOR_START = 20;

// WARNING: Do not use this free fn by itself, always inherit GelatoRelayFeeCollector
// solhint-disable-next-line func-visibility, private-vars-leading-underscore
function __getFeeCollector() pure returns (address feeCollector) {
    assembly {
        feeCollector := shr(
            96,
            calldataload(sub(calldatasize(), _FEE_COLLECTOR_START))
        )
    }
}

/**
 * @dev Context variant with only feeCollector appended to msg.data
 * Expects calldata encoding:
 *   abi.encodePacked(bytes data, address feeCollectorAddress)
 * Therefore, we're expecting 20bytes to be appended to normal msgData
 * 20bytes start offsets from calldatasize:
 *    feeCollector: -20
 */
/// @dev Do not use with GelatoRelayContext - pick only one
abstract contract GelatoRelayFeeCollector is GelatoRelayBase {
    function _getMsgData() internal view returns (bytes calldata) {
        return
            _isGelatoRelay(msg.sender)
                ? msg.data[:msg.data.length - _FEE_COLLECTOR_START]
                : msg.data;
    }

    // Only use with GelatoRelayBase onlyGelatoRelay or `_isGelatoRelay` checks
    function _getFeeCollector() internal pure returns (address) {
        return __getFeeCollector();
    }
}
