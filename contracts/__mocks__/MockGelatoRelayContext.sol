// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// import {
//     GelatoRelayContext
// } from "@gelatonetwork/relayer-context/contracts/GelatoRelayContext.sol";
import {GelatoRelayContext} from "../GelatoRelayContext.sol";

contract MockGelatoRelayContext is GelatoRelayContext {
    event LogMsgData(bytes msgData);
    event LogFnArgs(bytes fnArgs);
    event LogContext(address feeCollector, address feeToken, uint256 fee);

    function emitContext() external {
        emit LogMsgData(msg.data);
        emit LogFnArgs(_msgData());
        emit LogContext(_getFeeCollector(), _getFeeToken(), _getFee());
    }

    function testTransferRelayFee() external {
        _transferRelayFee();
    }

    function testTransferRelayFeeCapped(uint256 _maxFee) external {
        _transferRelayFeeCapped(_maxFee);
    }

    // solhint-disable-next-line no-empty-blocks
    function testOnlyRelayer() external onlyRelayer {}
}
