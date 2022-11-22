// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {GelatoRelayContext} from "../GelatoRelayContext.sol";
import "hardhat/console.sol";

contract MockGelatoRelayContext is GelatoRelayContext {
    event LogMsgData(bytes data);
    event LogContext(address feeCollector, address feeToken, uint256 fee);

    constructor(address _trustedForwarder)
        GelatoRelayContext(_trustedForwarder)
    {} // solhint-disable-line no-empty-blocks

    function emitContext() external {
        bytes calldata temp = _msgData();
        address feeCollector = _getFeeCollector();
        address feeToken = _getFeeToken();
        uint256 fee = _getFee();
        console.logBytes(temp);
        console.log(feeCollector);
        console.log(feeToken);
        console.log(fee);

        emit LogMsgData(_msgData());

        emit LogContext(_getFeeCollector(), _getFeeToken(), _getFee());
    }

    function testTransferRelayFee() external {
        _transferRelayFee();
    }

    function testTransferRelayFeeCapped(uint256 _maxFee) external {
        _transferRelayFeeCapped(_maxFee);
    }

    // solhint-disable-next-line no-empty-blocks
    function testOnlyGelatoRelay() external onlyGelatoRelay {}
}
