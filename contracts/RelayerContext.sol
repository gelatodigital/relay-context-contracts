// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {TokenUtils} from "./lib/TokenUtils.sol";
import "hardhat/console.sol";

/**
 * @dev Context variant with RelayerFee support.
 * Use RelayerFeeERC2771Context, if you need ERC2771 _msgSender support.
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
    address public immutable relayer;

    // RelayerContext
    uint256 internal constant _FEE_COLLECTOR_START = 60;
    uint256 internal constant _FEE_TOKEN_START = 40;
    uint256 internal constant _FEE_START = 20;

    modifier onlyRelayer() {
        require(_isRelayer(msg.sender), "RelayerContext.onlyRelayer");
        _;
    }

    constructor(address _relayer) {
        relayer = _relayer;
    }

    // DANGER! Only use with onlyRelayer `_isRelayer` before transferring
    function _uncheckedTransferToFeeCollectorUncapped() internal {
        _getFeeTokenUnchecked().transfer(
            _getFeeCollectorUnchecked(),
            _getFeeUnchecked()
        );
    }

    // DANGER! Only use with onlyRelayer `_isRelayer` before transferring
    function _uncheckedTransferToFeeCollectorCapped(uint256 _maxFee) internal {
        uint256 fee = _getFeeUnchecked();
        require(
            fee <= _maxFee,
            "RelayerContext._uncheckedTransferToFeeCollectorCapped: maxFee"
        );
        _getFeeTokenUnchecked().transfer(_getFeeCollectorUnchecked(), fee);
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
        console.log("_msgData");
        return
            _isRelayer(msg.sender)
                ? msg.data[:msg.data.length - _FEE_COLLECTOR_START]
                : msg.data;
    }

    function _getFeeCollector() internal view onlyRelayer returns (address) {
        console.log("_getFeeCollector");
        return
            abi.decode(
                msg.data[msg.data.length - _FEE_COLLECTOR_START:],
                (address)
            );
    }

    function _getFeeToken() internal view onlyRelayer returns (address) {
        console.log("_getFeeToken");
        return
            abi.decode(
                msg.data[msg.data.length - _FEE_TOKEN_START:],
                (address)
            );
    }

    function _getFee() internal view onlyRelayer returns (uint256) {
        console.log("_getFee");
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
