// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {TokenUtils} from "./lib/TokenUtils.sol";

/**
 * @dev Context variant with RelayerFee support.
 * Use RelayerFeeERC2771Context, if you need ERC2771 support.
 * Expects calldata encoding:
 *   abi.encodePacked(bytes fnArgs, address feeCollectorAddress, address feeToken, uint256 fee)
 * Therefore, we're expecting 3 * 32bytes (20hex) (60 hex total) to be appended to normal msgData
 * 32bytes (20 hex) start offsets from calldatasize:
 *     feeCollector: -60
 *     feeToken: -40
 *     fee: -20
 */
abstract contract RelayerContext {
    using TokenUtils for address;

    /// @dev Only use with a safe whitelisted trusted forwarder contract (e.g. GelatoRelay)
    address public immutable trustedForwarder;

    // RelayerFeeContext
    uint256 internal constant _FEE_COLLECTOR_START = 60;
    uint256 internal constant _FEE_TOKEN_START = 40;
    uint256 internal constant _FEE_START = 20;

    modifier isTrustedForwarder() {
        require(
            _isTrustedForwarder(msg.sender),
            "RelayerContext.isTrustedForwarder"
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
            "RelayerContext._transferFromThisToRelayerCapped: maxFee"
        );
        _getFeeTokenUnchecked().transfer(_getFeeCollectorUnchecked(), fee);
    }

    function _isTrustedForwarder(address _forwarder)
        internal
        view
        virtual
        returns (bool)
    {
        return _forwarder == trustedForwarder;
    }

    /// Use RelayerFeeERC2771Context if you expect the ERC2771 behavior.
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
}
