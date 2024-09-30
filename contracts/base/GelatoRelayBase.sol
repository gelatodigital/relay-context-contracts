// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {
    GelatoRelayContractsUtils
} from "../utils/GelatoRelayContractsUtils.sol";
import {
    GELATO_RELAY_V1,
    GELATO_RELAY_V2,
    GELATO_RELAY_ZKSYNC
} from "../constants/GelatoRelay.sol";

abstract contract GelatoRelayBase is GelatoRelayContractsUtils {
    modifier onlyGelatoRelay() {
        require(_isGelatoRelay(msg.sender), "onlyGelatoRelay");
        _;
    }

    function _isGelatoRelay(address _forwarder) internal view returns (bool) {
        if (isZkSyncChainId(block.chainid)) {
            return _forwarder == GELATO_RELAY_ZKSYNC;
        }
        if (isV1ChainId(block.chainid)) {
            return _forwarder == GELATO_RELAY_V1;
        }
        return _forwarder == GELATO_RELAY_V2;
    }
}
