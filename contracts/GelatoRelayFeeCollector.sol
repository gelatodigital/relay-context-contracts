// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoRelayBase} from "./base/GelatoRelayBase.sol";
uint256 constant _FEE_COLLECTOR_START = 32;

// WARNING: Do not use this free fn by itself, always inherit GelatoRelayFeeCollector
// solhint-disable-next-line func-visibility, private-vars-leading-underscore
function __getFeeCollector() pure returns (address) {
    return
        abi.decode(
            msg.data[msg.data.length - _FEE_COLLECTOR_START:],
            (address)
        );
}

/**
 * @dev Context variant with only feeCollector appended to msg.data
 * Expects calldata encoding:
 *   abi.encodePacked(bytes data, address feeCollectorAddress)
 * Therefore, we're expecting 32bytes to be appended to normal msgData
 * 32bytes start offsets from calldatasize:
 *    feeCollector: - 32
 */
/// @dev Do not use with GelatoRelayFeeCollector - pick only one
abstract contract GelatoRelayFeeCollector is GelatoRelayBase {
    // Do not confuse with OZ Context.sol _msgData()
    function __msgData() internal view returns (bytes calldata) {
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
