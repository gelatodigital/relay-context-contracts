// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {GelatoRelayERC2771Base} from "./base/GelatoRelayERC2771Base.sol";
import {TokenUtils} from "./lib/TokenUtils.sol";
import {ERC2771Context} from "./vendor/ERC2771Context.sol";

uint256 constant _FEE_COLLECTOR_START = 92; // offset: address + address + uint256 + address
uint256 constant _FEE_TOKEN_START = 72; // offset: address + uint256 + address
uint256 constant _FEE_START = 52; // offset: uint256 + address
uint256 constant _MSG_SENDER_START = 20; // offset: address

// WARNING: Do not use this free fn by itself, always inherit GelatoRelayContextERC2771
// solhint-disable-next-line func-visibility, private-vars-leading-underscore
function _getFeeCollectorRelayContextERC2771()
    pure
    returns (address feeCollector)
{
    assembly {
        feeCollector := shr(
            96,
            calldataload(sub(calldatasize(), _FEE_COLLECTOR_START))
        )
    }
}

// WARNING: Do not use this free fn by itself, always inherit GelatoRelayContextERC2771
// solhint-disable-next-line func-visibility, private-vars-leading-underscore
function _getFeeTokenRelayContextERC2771() pure returns (address feeToken) {
    assembly {
        feeToken := shr(96, calldataload(sub(calldatasize(), _FEE_TOKEN_START)))
    }
}

// WARNING: Do not use this free fn by itself, always inherit GelatoRelayContextERC2771
// solhint-disable-next-line func-visibility, private-vars-leading-underscore
function _getFeeRelayContextERC2771() pure returns (uint256 fee) {
    assembly {
        fee := calldataload(sub(calldatasize(), _FEE_START))
    }
}

// WARNING: Do not use this free fn by itself, always inherit GelatoRelayContextERC2771
// solhint-disable-next-line func-visibility, private-vars-leading-underscore
function _getMsgSenderRelayContextERC2771() pure returns (address _msgSender) {
    assembly {
        _msgSender := shr(
            96,
            calldataload(sub(calldatasize(), _MSG_SENDER_START))
        )
    }
}

/**
 * @dev Context variant with feeCollector, feeToken, fee, _msgSender appended to msg.data
 * Expects calldata encoding:
    abi.encodePacked(
        _data,
        _feeCollector,
        _feeToken,
        _fee,
        _msgSender
    );
 * Therefore, we're expecting 20 + 20 + 32 + 20 = 92 bytes to be appended to normal msgData
 *     feeCollector: - 92 bytes
 *     feeToken: - 72 bytes
 *     fee: - 52 bytes
 *     _msgSender: - 20 bytes
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
abstract contract GelatoRelayContextERC2771 is
    ERC2771Context,
    GelatoRelayERC2771Base
{
    using TokenUtils for address;

    // solhint-disable-next-line no-empty-blocks
    constructor(address _trustedForwarder) ERC2771Context(_trustedForwarder) {}

    // DANGER! Only use with onlyGelatoRelayERC2771 or `_isGelatoRelayERC2771` checks
    function _transferRelayFee() internal {
        _getFeeToken().transfer(_getFeeCollector(), _getFee());
    }

    // DANGER! Only use with onlyGelatoRelayERC2771 or `_isGelatoRelayERC2771` checks
    function _transferRelayFeeCapped(uint256 _maxFee) internal {
        uint256 fee = _getFee();
        require(
            fee <= _maxFee,
            "GelatoRelayContextERC2771._transferRelayFeeCapped: maxFee"
        );
        _getFeeToken().transfer(_getFeeCollector(), fee);
    }

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
                ? _getMsgSenderRelayContextERC2771()
                : super._msgSender();
    }

    // Only use with GelatoRelayERC2771Base onlyGelatoRelayERC2771 or `_isGelatoRelayERC2771` checks
    function _getFeeCollector() internal pure returns (address) {
        return _getFeeCollectorRelayContextERC2771();
    }

    // Only use with GelatoRelayERC2771Base onlyGelatoRelayERC2771 or `_isGelatoRelayERC2771` checks
    function _getFeeToken() internal pure returns (address) {
        return _getFeeTokenRelayContextERC2771();
    }

    // Only use with GelatoRelayERC2771Base onlyGelatoRelayERC2771 or `_isGelatoRelayERC2771` checks
    function _getFee() internal pure returns (uint256) {
        return _getFeeRelayContextERC2771();
    }
}
