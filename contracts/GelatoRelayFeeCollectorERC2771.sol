// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoRelayERC2771Base} from "./base/GelatoRelayERC2771Base.sol";

uint256 constant _FEE_COLLECTOR_START = 40; // offset: address + address
uint256 constant _MSG_SENDER_START = 20; // offset: address

// WARNING: Do not use this free fn by itself, always inherit GelatoRelayFeeCollectorERC2771
// solhint-disable-next-line func-visibility, private-vars-leading-underscore
function _getFeeCollectorERC2771() pure returns (address feeCollector) {
    assembly {
        feeCollector := shr(
            96,
            calldataload(sub(calldatasize(), _FEE_COLLECTOR_START))
        )
    }
}

// WARNING: Do not use this free fn by itself, always inherit GelatoRelayContextERC2771
// solhint-disable-next-line func-visibility, private-vars-leading-underscore
function _getMsgSenderFeeCollectorERC2771() pure returns (address _msgSender) {
    assembly {
        _msgSender := shr(
            96,
            calldataload(sub(calldatasize(), _MSG_SENDER_START))
        )
    }
}

/**
 * @dev Context variant with feeCollector + _msgSender() appended to msg.data
 * Expects calldata encoding:
 *   abi.encodePacked(bytes data, address feeCollectorAddress, address _msgSender)
 * Therefore, we're expecting 40 bytes to be appended to normal msgData
 *    feeCollector: - 40 bytes
 *    _msgSender: - 20 bytes
 */

/// @dev Do not use with GelatoRelayFeeCollectorERC2771 - pick only one
abstract contract GelatoRelayFeeCollectorERC2771 is GelatoRelayERC2771Base {
    function _getMsgData() internal view returns (bytes calldata) {
        return
            _isGelatoRelayERC2771(msg.sender)
                ? msg.data[:msg.data.length - _FEE_COLLECTOR_START]
                : msg.data;
    }

    function _getMsgSender() internal view returns (address) {
        return
            _isGelatoRelayERC2771(msg.sender)
                ? _getMsgSenderFeeCollectorERC2771()
                : msg.sender;
    }

    // Only use with GelatoRelayERC2771Base onlyGelatoRelayERC2771 or `_isGelatoRelayERC2771` checks
    function _getFeeCollector() internal pure returns (address) {
        return _getFeeCollectorERC2771();
    }
}
