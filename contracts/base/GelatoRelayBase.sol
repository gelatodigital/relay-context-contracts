// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GELATO_RELAY, GELATO_RELAY_ZKSYNC} from "../constants/GelatoRelay.sol";

abstract contract GelatoRelayBase {
    modifier onlyGelatoRelay() {
        require(_isGelatoRelay(msg.sender), "onlyGelatoRelay");
        _;
    }

    function _isGelatoRelay(address _forwarder) internal view returns (bool) {
        return
            block.chainid == 324 || block.chainid == 280
                ? _forwarder == GELATO_RELAY_ZKSYNC
                : _forwarder == GELATO_RELAY;
    }
}
