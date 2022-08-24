// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {TokenUtils} from "./lib/TokenUtils.sol";

// solhint-disable max-line-length
/**
 * @dev Context variant with RelayerContextERC2771 and ERC2771Context support.
 * Inherit plain RelayerFeeContext instead, if you do not need ERC2771 support.
 * Expects calldata encoding:
 *   abi.encodePacked(bytes fnArgs, address feeCollector, address feeToken, uint256 fee, address sender)
 * Therefore, we're expecting 4 * 32bytes (20hex) (80 hex total) to be appended to fnArgs
 * 32bytes (20 hex) start offsets from calldatasize:
 *     feeCollector: -80
 *     feeToken: -60
 *     fee: -40
 *     sender: -20
 */
// solhint-enable max-line-length
abstract contract RelayerContextERC2771 {
    using TokenUtils for address;

    /// @dev Only use with a safe whitelisted trusted forwarder contract (e.g. GelatoRelay)
    address public immutable trustedForwarder;

    // RelayerFeeContext
    uint256 private constant _FEE_COLLECTOR_START = 80;
    uint256 private constant _FEE_TOKEN_START = 60;
    uint256 private constant _FEE_START = 40;

    // ERC2771Context
    uint256 private constant _SENDER_START = 20;

    modifier isTrustedForwarder() {
        require(
            _isTrustedForwarder(msg.sender),
            "RelayerContextERC2771.isTrustedForwarder"
        );
        _;
    }

    constructor(address _trustedForwarder) {
        trustedForwarder = _trustedForwarder;
    }

    function _transferFromThisToRelayerUncapped() internal isTrustedForwarder {
        _getFeeTokenUnchecked().transfer(
            _getFeeCollectorUnchecked(),
            _getFeeUnchecked()
        );
    }

    function _transferFromThisToRelayerCapped(uint256 _maxFee)
        internal
        isTrustedForwarder
    {
        uint256 fee = _getFeeUnchecked();
        require(
            fee <= _maxFee,
            "RelayerContextERC2771._transferFromThisToRelayerCapped: maxFee"
        );
        _getFeeTokenUnchecked().transfer(_getFeeCollectorUnchecked(), fee);
    }

    function _transferFromSenderToRelayerUncapped()
        internal
        isTrustedForwarder
    {
        _getFeeTokenUnchecked().transferFrom(
            _msgSenderUnchecked(),
            _getFeeCollectorUnchecked(),
            _getFeeUnchecked()
        );
    }

    function _transferFromSenderToRelayerCapped(uint256 _maxFee)
        internal
        isTrustedForwarder
    {
        uint256 fee = _getFeeUnchecked();
        require(
            fee <= _maxFee,
            "RelayerContextERC2771._transferFromSenderToRelayerCapped: maxFee"
        );
        _getFeeTokenUnchecked().transferFrom(
            _msgSenderUnchecked(),
            _getFeeCollectorUnchecked(),
            fee
        );
    }

    function _isTrustedForwarder(address _forwarder)
        internal
        view
        returns (bool)
    {
        return _forwarder == trustedForwarder;
    }

    function _msgData() internal view returns (bytes calldata) {
        return
            _isTrustedForwarder(msg.sender)
                ? msg.data[:msg.data.length - _FEE_COLLECTOR_START]
                : msg.data;
    }

    function _getFeeCollector()
        internal
        view
        isTrustedForwarder
        returns (address)
    {
        return
            abi.decode(
                msg.data[msg.data.length - _FEE_COLLECTOR_START:],
                (address)
            );
    }

    function _getFeeToken() internal view isTrustedForwarder returns (address) {
        return
            abi.decode(
                msg.data[msg.data.length - _FEE_TOKEN_START:],
                (address)
            );
    }

    function _getFee() internal view isTrustedForwarder returns (uint256) {
        return abi.decode(msg.data[msg.data.length - _FEE_START:], (uint256));
    }

    function _msgSender() internal view returns (address) {
        return
            _isTrustedForwarder(msg.sender)
                ? abi.decode(
                    msg.data[msg.data.length - _SENDER_START:],
                    (address)
                )
                : msg.sender;
    }

    function _getFeeCollectorUnchecked() internal pure returns (address) {
        return
            abi.decode(
                msg.data[msg.data.length - _FEE_COLLECTOR_START:],
                (address)
            );
    }

    function _getFeeTokenUnchecked() internal pure returns (address) {
        return
            abi.decode(
                msg.data[msg.data.length - _FEE_TOKEN_START:],
                (address)
            );
    }

    function _getFeeUnchecked() internal pure returns (uint256) {
        return abi.decode(msg.data[msg.data.length - _FEE_START:], (uint256));
    }

    function _msgSenderUnchecked() internal pure returns (address) {
        return
            abi.decode(msg.data[msg.data.length - _SENDER_START:], (address));
    }
}
