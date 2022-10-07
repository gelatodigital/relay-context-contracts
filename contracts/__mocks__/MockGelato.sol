// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {
    ExecWithSigsFeeCollector,
    ExecWithSigsRelayContext
} from "../types/CallTypes.sol";
import {GelatoBytes} from "../lib/GelatoBytes.sol";
import {GelatoCallUtils} from "../lib/GelatoCallUtils.sol";
import {
    _encodeFeeCollector,
    _encodeGelatoRelayContext
} from "../functions/GelatoRelayUtils.sol";

contract MockGelato {
    using GelatoCallUtils for address;

    address public immutable feeCollector;

    constructor(address _feeCollector) {
        feeCollector = _feeCollector;
    }

    function execWithSigsFeeCollector(ExecWithSigsFeeCollector calldata _call)
        external
    {
        // call forward + append fee collector
        (bool success, bytes memory returndata) = _call.msg.service.call(
            _encodeFeeCollector(_call.msg.data, feeCollector)
        );

        if (!success)
            GelatoBytes.revertWithError(
                returndata,
                "ExecWithSigsFacet.execWithSigsSyncFee:"
            );
    }

    function execWithSigsRelayContext(ExecWithSigsRelayContext calldata _call)
        external
    {
        // call forward + append fee collector, feeToken, fee
        _call.msg.service.revertingContractCall(
            _encodeGelatoRelayContext(
                _call.msg.data,
                feeCollector,
                _call.msg.feeToken,
                _call.msg.fee
            ),
            "ExecWithSigsFacet.execWithSigsRelayContext:"
        );
    }
}
