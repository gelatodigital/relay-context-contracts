// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {
    RelayerContext
} from "@gelatonetwork/relayer-context/contracts/RelayerContext.sol";
import "hardhat/console.sol";

contract MockRelayerContext is RelayerContext {
    event LogMsgData(bytes msgData);
    event LogValues(
        bytes fnArgs,
        address feeCollector,
        address feeToken,
        uint256 fee
    );
    event LogUncheckedValues(
        bytes fnArgs,
        address feeCollector,
        address feeToken,
        uint256 fee
    );

    // solhint-disable-next-line no-empty-blocks
    constructor(address _mockRelayer) RelayerContext(_mockRelayer) {}

    function onlyRelayerTransferUncapped() external onlyRelayer {
        // _uncheckedTransferToFeeCollectorUncapped();

        console.log("enter onlyRelayerTransferUncapped");

        emit LogMsgData(msg.data);

        // emit LogValues(
        //     _msgData(),
        //     _getFeeCollector(),
        //     _getFeeToken(),
        //     _getFee()
        // );

        // emit LogUncheckedValues(
        //     _msgData(),
        //     _getFeeCollectorUnchecked(),
        //     _getFeeTokenUnchecked(),
        //     _getFeeUnchecked()
        // );
    }

    function onlyRelayerTransferCapped(uint256 _maxFee) external onlyRelayer {
        _uncheckedTransferToFeeCollectorCapped(_maxFee);

        emit LogValues(
            _msgData(),
            _getFeeCollector(),
            _getFeeToken(),
            _getFee()
        );

        emit LogUncheckedValues(
            _msgData(),
            _getFeeCollectorUnchecked(),
            _getFeeTokenUnchecked(),
            _getFeeUnchecked()
        );
    }
}
