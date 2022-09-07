// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {TokenUtils} from "./lib/TokenUtils.sol";

/**
 * @dev Context variant with RelayerFee support.
 * Expects calldata encoding:
 *   abi.encodePacked(bytes fnArgs, address feeCollectorAddress, address feeToken, uint256 fee)
 * Therefore, we're expecting 3 * 32bytes to be appended to normal msgData
 * 32bytes start offsets from calldatasize:
 *     feeCollector: - 32 * 3
 *     feeToken: - 32 * 2
 *     fee: - 32
 */
abstract contract RelayerContext {
    using TokenUtils for address;

    /// @dev Only use with a safe whitelisted trusted forwarder contract (e.g. GelatoRelay)
    address public immutable relayer;

    // RelayerContext
    uint256 internal constant _FEE_COLLECTOR_START = 3 * 32;
    uint256 internal constant _FEE_TOKEN_START = 2 * 32;
    uint256 internal constant _FEE_START = 32;

    modifier onlyRelayer() {
        require(_isRelayer(msg.sender), "RelayerContext.onlyRelayer");
        _;
    }

    constructor(address _relayer) {
        relayer = _relayer;
    }

    // DANGER! Only use with onlyRelayer `_isRelayer` before transferring
    function _transferToFeeCollectorUncapped() internal {
        _getFeeToken().transfer(_getFeeCollector(), _getFee());
    }

    // DANGER! Only use with onlyRelayer `_isRelayer` before transferring
    function _transferToFeeCollectorCapped(uint256 _maxFee) internal {
        uint256 fee = _getFee();
        require(
            fee <= _maxFee,
            "RelayerContext._transferToFeeCollectorCapped: maxFee"
        );
        _getFeeToken().transfer(_getFeeCollector(), fee);
    }

    function _isRelayer(address _forwarder)
        internal
        view
        virtual
        returns (bool)
    {
        return _forwarder == relayer;
    }

    function _msgData() internal view returns (bytes calldata) {
        return
            _isRelayer(msg.sender)
                ? msg.data[:msg.data.length - _FEE_COLLECTOR_START]
                : msg.data;
    }

    // Only use with previous onlyRelayer or `_isRelayer` checks
    function _getFeeCollector() internal pure returns (address) {
        return
            abi.decode(
                msg.data[msg.data.length - _FEE_COLLECTOR_START:],
                (address)
            );
    }

    // Only use with previous onlyRelayer or `_isRelayer` checks
    function _getFeeToken() internal pure returns (address) {
        return
            abi.decode(
                msg.data[msg.data.length - _FEE_TOKEN_START:],
                (address)
            );
    }

    // Only use with previous onlyRelayer or `_isRelayer` checks
    function _getFee() internal pure returns (uint256) {
        return abi.decode(msg.data[msg.data.length - _FEE_START:], (uint256));
    }
}
