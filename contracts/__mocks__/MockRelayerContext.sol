// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// import {
//     RelayerContext
// } from "@gelatonetwork/relayer-context/contracts/RelayerContext.sol";
import {RelayerContext} from "../RelayerContext.sol";
import "hardhat/console.sol";

contract MockRelayerContext is RelayerContext {
    event LogMsgData(bytes msgData);
    event LogFnArgs(bytes fnArgs);
    event LogContext(address feeCollector, address feeToken, uint256 fee);
    event LogUncheckedContext(
        address feeCollector,
        address feeToken,
        uint256 fee
    );

    // solhint-disable-next-line no-empty-blocks
    constructor(address _mockRelayer) RelayerContext(_mockRelayer) {}

    function emitContext() external {
        emit LogMsgData(msg.data);
        emit LogFnArgs(_msgData());
        emit LogContext(_getFeeCollector(), _getFeeToken(), _getFee());
        emit LogUncheckedContext(
            _getFeeCollectorUnchecked(),
            _getFeeTokenUnchecked(),
            _getFeeUnchecked()
        );
    }

    function onlyRelayerTransferUncapped() external onlyRelayer {
        _uncheckedTransferToFeeCollectorUncapped();
    }

    function onlyRelayerTransferCapped(uint256 _maxFee) external onlyRelayer {
        _uncheckedTransferToFeeCollectorCapped(_maxFee);

        emit LogContext(_getFeeCollector(), _getFeeToken(), _getFee());
        emit LogUncheckedContext(
            _getFeeCollectorUnchecked(),
            _getFeeTokenUnchecked(),
            _getFeeUnchecked()
        );
    }
}
