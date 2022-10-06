// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {TokenUtils} from "./lib/TokenUtils.sol";
import {GELATO_RELAY} from "./constants/GelatoRelay.sol";

abstract contract GelatoRelayContext {
    using TokenUtils for address;

    uint256 internal constant _FEE_COLLECTOR_START = 32;
    uint256 internal constant _RELAY_CONTEXT_START = 3 * 32;

    /// @dev PERMISSIONING MODIFIER

    modifier onlyGelatoRelay() {
        require(
            _isGelatoRelay(msg.sender),
            "GelatoRelayContext.onlyGelatoRelay"
        );
        _;
    }

    /// @dev TRANSFER FUNCTIONS

    // DANGER! Only use with onlyGelatoRelay `_isGelatoRelay` before transferring
    function _transferRelayFee() internal {
        (
            address feeCollector,
            address feeToken,
            uint256 fee
        ) = _getRelayContext();

        feeToken.transfer(feeCollector, fee);
    }

    // DANGER! Only use with onlyGelatoRelay `_isGelatoRelay` before transferring
    function _transferRelayFeeCapped(uint256 _maxFee) internal {
        (
            address feeCollector,
            address feeToken,
            uint256 fee
        ) = _getRelayContext();

        require(
            fee <= _maxFee,
            "GelatoRelayContext._transferRelayFeeCapped: maxFee"
        );

        feeToken.transfer(feeCollector, fee);
    }

    /// @dev DECODING ORIGINAL MSG.DATA FUNCTIONS

    function _msgDataFeeCollector() internal view returns (bytes calldata) {
        return
            _isGelatoRelay(msg.sender)
                ? msg.data[:msg.data.length - _FEE_COLLECTOR_START]
                : msg.data;
    }

    function _msgDataRelayContext() internal view returns (bytes calldata) {
        return
            _isGelatoRelay(msg.sender)
                ? msg.data[:msg.data.length - _RELAY_CONTEXT_START]
                : msg.data;
    }

    /// @dev PERMISSIONING FUNCTION

    function _isGelatoRelay(address _forwarder)
        internal
        view
        virtual
        returns (bool)
    {
        return _forwarder == GELATO_RELAY;
    }

    /// @dev DECODING FUNCTIONS

    /**
     * @dev Context variant with only feeCollector appended to msg.data
     * Expects calldata encoding:
     *   abi.encodePacked(bytes data, address feeCollectorAddress)
     * Therefore, we're expecting 32bytes to be appended to normal msgData
     * 32bytes start offsets from calldatasize:
     *    feeCollector: - 32
     */
    // Only use with previous onlyGelatoRelay or `_isGelatoRelay` checks
    function _getFeeCollector() internal pure returns (address) {
        return
            abi.decode(
                msg.data[msg.data.length - _FEE_COLLECTOR_START:],
                (address)
            );
    }

    /**
     * @dev Context variant with feeCollector, feeToken and fee appended to msg.data
     * Expects calldata encoding:
     *   abi.encodePacked(bytes data, address feeCollectorAddress, address feeToken, uint256 fee)
     * Therefore, we're expecting 3 * 32bytes to be appended to normal msgData
     * 32bytes start offsets from calldatasize:
     *     feeCollector: - 32 * 3
     *     feeToken: - 32 * 2
     *     fee: - 32
     */
    function _getRelayContext()
        internal
        pure
        returns (
            address feeCollector,
            address feeToken,
            uint256 fee
        )
    {
        return
            abi.decode(
                msg.data[msg.data.length - _RELAY_CONTEXT_START:],
                (address, address, uint256)
            );
    }

    /// @dev ENCODING FUNCTION

    function _encodeGelatoRelayContext(
        bytes calldata _data,
        address _feeCollector,
        address _feeToken,
        uint256 _fee
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(_data, abi.encode(_feeCollector, _feeToken, _fee));
    }
}
