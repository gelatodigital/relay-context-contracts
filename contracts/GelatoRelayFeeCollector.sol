// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {GelatoRelayBase} from "./base/GelatoRelayBase.sol";
import {
    ERC2771Context
} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";

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
/// @dev Do not use with GelatoRelayFeeCollector - pick only one
abstract contract GelatoRelayFeeCollector is ERC2771Context, GelatoRelayBase {
    // solhint-disable-next-line no-empty-blocks
    constructor(address _trustedForwarder) ERC2771Context(_trustedForwarder) {}

    /// @dev automatic ERC2771Context support from OZ: you can set a trustedForwarder
    /// and use OZ's ERC2771Context as needed.
    function _msgData() internal view override returns (bytes calldata) {
        return
            _isGelatoRelay(msg.sender)
                ? msg.data[:msg.data.length - _FEE_COLLECTOR_START]
                : super._msgData();
    }

    // Only use with GelatoRelayBase onlyGelatoRelay or `_isGelatoRelay` checks
    function _getFeeCollector() internal pure returns (address) {
        return __getFeeCollector();
    }
}
