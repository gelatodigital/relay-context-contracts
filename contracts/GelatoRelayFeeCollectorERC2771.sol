// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {GelatoRelayERC2771Base} from "./base/GelatoRelayERC2771Base.sol";
import {ERC2771Context} from "./vendor/ERC2771Context.sol";

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

/**
 * @dev If you are using in combination with ERC2771Context from OpenZeppellin
 * i.e. you are wanting to use multiple relayers
 * https://docs.openzeppelin.com/contracts/4.x/api/metatx
 * You will have to set a `trustedForwarder` in your target contract's constructor:
 * constructor(address _trustedForwarder) GelatoRelayContextERC2771(_trustedForwarder);
 *
 * You can set the `trustedForwarder` as:
 * 1. A trusted relayer address other than GelatoRelayERC2771.sol
 * 2. If no backup relayer is needed, and you are only using Gelato Relay:
 *      a. set `trustedForwarder` to address(0)
 * 3. Otherwise, DO NOT set the trustedForwarder as GelatoRealyERC2771
 *      a. this is hard coded already, please use either:
 *          I. onlyGelatoRelayERC2771()
 *          II. _isGelatoRelayERC2771()
 */

/// @dev Do not use with GelatoRelayFeeCollectorERC2771 - pick only one
abstract contract GelatoRelayFeeCollectorERC2771 is
    ERC2771Context,
    GelatoRelayERC2771Base
{
    // solhint-disable-next-line no-empty-blocks
    constructor(address _trustedForwarder) ERC2771Context(_trustedForwarder) {}

    function _msgData()
        internal
        view
        virtual
        override
        returns (bytes calldata)
    {
        return
            _isGelatoRelayERC2771(msg.sender)
                ? msg.data[:msg.data.length - _FEE_COLLECTOR_START]
                : super._msgData();
    }

    function _msgSender() internal view virtual override returns (address) {
        return
            _isGelatoRelayERC2771(msg.sender)
                ? _getMsgSenderFeeCollectorERC2771()
                : super._msgSender();
    }

    // Only use with GelatoRelayERC2771Base onlyGelatoRelayERC2771 or `_isGelatoRelayERC2771` checks
    function _getFeeCollector() internal pure returns (address) {
        return _getFeeCollectorERC2771();
    }
}
