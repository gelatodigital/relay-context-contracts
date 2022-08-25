// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {TokenUtils} from "./lib/TokenUtils.sol";

// solhint-disable max-line-length
/**
 * @dev Context variant with RelayerContextERC2771 and ERC2771Context support.
 * Inherit plain RelayerContext instead, if you do not need ERC2771 support.
 * Expects calldata encoding:
 *   abi.encodePacked(
 *     abi.encodePacked(
 *        bytes fnArgs,
 *        abi.encode(address feeCollector, address feeToken, uint256 fee)
 *     ),
 *     sender
 *   )
 * Therefore, we're expecting 3 * 32bytes and 20 bytes to be appended to fnArgs
 * 32bytes start offsets from calldatasize:
 *     feeCollector: - 3 * 32 + 20
 *     feeToken: - 2 * 32 + 20
 *     fee: - 32 + 20
 *     sender: - 20
 */
// solhint-enable max-line-length
abstract contract RelayerContextERC2771 {
    using TokenUtils for address;

    /// @dev Only use with a safe whitelisted trusted forwarder contract (e.g. GelatoRelay)
    address public immutable relayer;

    // RelayerContext
    uint256 private constant _FEE_COLLECTOR_START = 3 * 32 + 20;
    uint256 private constant _FEE_TOKEN_START = 2 * 32 + 20;
    uint256 private constant _FEE_START = 32 + 20;

    // ERC2771Context
    uint256 private constant _SENDER_START = 20;

    modifier onlyRelayer() {
        require(_isRelayer(msg.sender), "RelayerContextERC2771.onlyRelayer");
        _;
    }

    constructor(address _relayer) {
        relayer = _relayer;
    }

    // DANGER! Only use with onlyRelayer or `_isRelayer` before transferring
    function _uncheckedTransferToFeeCollectorUncapped() internal {
        _getFeeTokenUnchecked().transfer(
            _getFeeCollectorUnchecked(),
            _getFeeUnchecked()
        );
    }

    // DANGER! Only use with onlyRelayer or `_isRelayer` before transferring
    function _uncheckedTransferToFeeCollectorCapped(uint256 _maxFee)
        internal
        onlyRelayer
    {
        uint256 fee = _getFeeUnchecked();
        require(
            fee <= _maxFee,
            "RelayerContextERC2771._uncheckedTransferToFeeCollectorCapped: maxFee"
        );
        _getFeeTokenUnchecked().transfer(_getFeeCollectorUnchecked(), fee);
    }

    // DANGER! Only use with onlyRelayer or `_isRelayer` before transferring
    function _uncheckedTransferFromSenderToFeeCollectorUncapped() internal {
        _getFeeTokenUnchecked().transferFrom(
            _msgSenderUnchecked(),
            _getFeeCollectorUnchecked(),
            _getFeeUnchecked()
        );
    }

    // DANGER! Only use with onlyRelayer or `_isRelayer` before transferring
    function _unckeckedTransferFromSenderToFeeCollectorCapped(uint256 _maxFee)
        internal
    {
        uint256 fee = _getFeeUnchecked();
        require(
            fee <= _maxFee,
            "RelayerContextERC2771._unckeckedTransferFromSenderToFeeCollectorCapped: maxFee"
        );
        _getFeeTokenUnchecked().transferFrom(
            _msgSenderUnchecked(),
            _getFeeCollectorUnchecked(),
            fee
        );
    }

    function _isRelayer(address _forwarder) internal view returns (bool) {
        return _forwarder == relayer;
    }

    function _msgData() internal view returns (bytes calldata) {
        return
            _isRelayer(msg.sender)
                ? msg.data[:msg.data.length - _FEE_COLLECTOR_START]
                : msg.data;
    }

    function _getFeeCollector() internal view onlyRelayer returns (address) {
        return
            abi.decode(
                msg.data[msg.data.length - _FEE_COLLECTOR_START:],
                (address)
            );
    }

    function _getFeeToken() internal view onlyRelayer returns (address) {
        return
            abi.decode(
                msg.data[msg.data.length - _FEE_TOKEN_START:],
                (address)
            );
    }

    function _getFee() internal view onlyRelayer returns (uint256) {
        return abi.decode(msg.data[msg.data.length - _FEE_START:], (uint256));
    }

    function _msgSender() internal view returns (address) {
        return
            _isRelayer(msg.sender)
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
