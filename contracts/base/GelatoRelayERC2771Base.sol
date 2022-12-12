// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GELATO_RELAY_ERC2771} from "../constants/GelatoRelay.sol";

abstract contract GelatoRelayERC2771Base {
    modifier onlyGelatoRelayERC2771() {
        require(_isGelatoRelayERC2771(msg.sender), "onlyGelatoRelayERC2771");
        _;
    }

    function _isGelatoRelayERC2771(address _forwarder)
        internal
        pure
        returns (bool)
    {
        return _forwarder == GELATO_RELAY_ERC2771;
    }
}
