// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {
    RelayerContext
} from "@gelatonetwork/relayer-context/contracts/RelayerContext.sol";

contract MockRelayerContext is RelayerContext {
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
    constructor(address _mockRelay) RelayerContext(_mockRelay) {}

    function onlyRelayerTransferUncapped() external onlyRelayer {
        // _uncheckedTransferToFeeCollectorUncapped();

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

    function onlyRelayerTransferCapped(uint256 _maxFee) external onlyRelayer {
        // _uncheckedTransferToFeeCollectorCapped(_maxFee);

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
