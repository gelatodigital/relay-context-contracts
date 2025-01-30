// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {
    GelatoRelayContractsUtils
} from "../utils/GelatoRelayContractsUtils.sol";
import {
    GELATO_RELAY_ERC2771_V1,
    GELATO_RELAY_CONCURRENT_ERC2771_V1,
    GELATO_RELAY_ERC2771_V2,
    GELATO_RELAY_CONCURRENT_ERC2771_V2,
    GELATO_RELAY_ERC2771_ZKSYNC_V1,
    GELATO_RELAY_CONCURRENT_ERC2771_ZKSYNC_V1,
    GELATO_RELAY_ERC2771_ZKSYNC_V2,
    GELATO_RELAY_CONCURRENT_ERC2771_ZKSYNC_V2
} from "../constants/GelatoRelay.sol";

abstract contract GelatoRelayERC2771Base is GelatoRelayContractsUtils {
    modifier onlyGelatoRelayERC2771() {
        require(_isGelatoRelayERC2771(msg.sender), "onlyGelatoRelayERC2771");
        _;
    }

    function _isGelatoRelayERC2771(address _forwarder)
        internal
        view
        returns (bool)
    {
        // Use another address on zkSync
        if (_isV1ZkSyncChainId) {
            return (_forwarder == GELATO_RELAY_ERC2771_ZKSYNC_V1 ||
                _forwarder == GELATO_RELAY_CONCURRENT_ERC2771_ZKSYNC_V1);
        }
        if (_isV2ZkSyncChainId) {
            return (_forwarder == GELATO_RELAY_ERC2771_ZKSYNC_V2 ||
                _forwarder == GELATO_RELAY_CONCURRENT_ERC2771_ZKSYNC_V2);
        }
        if (_isV1ChainId) {
            return (_forwarder == GELATO_RELAY_ERC2771_V1 ||
                _forwarder == GELATO_RELAY_CONCURRENT_ERC2771_V1);
        }
        return (_forwarder == GELATO_RELAY_ERC2771_V2 ||
            _forwarder == GELATO_RELAY_CONCURRENT_ERC2771_V2);
    }
}
