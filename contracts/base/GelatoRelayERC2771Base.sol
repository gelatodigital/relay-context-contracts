// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {
    GELATO_RELAY_ERC2771,
    GELATO_RELAY_CONCURRENT_ERC2771,
    GELATO_RELAY_ERC2771_ZKSYNC,
    GELATO_RELAY_CONCURRENT_ERC2771_ZKSYNC
} from "../constants/GelatoRelay.sol";

abstract contract GelatoRelayERC2771Base {
    modifier onlyGelatoRelayERC2771() {
        require(_isGelatoRelayERC2771(msg.sender), "onlyGelatoRelayERC2771");
        _;
    }

    modifier onlyGelatoRelayConcurrentERC2771() {
        require(
            _isGelatoRelayERC2771(msg.sender),
            "onlyGelatoRelayConcurrentERC2771"
        );
        _;
    }

    function _isGelatoRelayERC2771(address _forwarder)
        internal
        view
        returns (bool)
    {
        // Use another address on zkSync
        if (block.chainid == 324 || block.chainid == 280) {
            return _forwarder == GELATO_RELAY_ERC2771_ZKSYNC;
        }
        return _forwarder == GELATO_RELAY_ERC2771;
    }

    function _isGelatoRelayConcurrentERC2771(address _forwarder)
        internal
        view
        returns (bool)
    {
        // Use another address on zkSync
        if (block.chainid == 324 || block.chainid == 280) {
            return _forwarder == GELATO_RELAY_CONCURRENT_ERC2771_ZKSYNC;
        }
        return _forwarder == GELATO_RELAY_CONCURRENT_ERC2771;
    }
}
