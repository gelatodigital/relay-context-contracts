// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {
    GelatoRelayContractsUtils
} from "../utils/GelatoRelayContractsUtils.sol";

abstract contract GelatoRelayBase is GelatoRelayContractsUtils {
    modifier onlyGelatoRelay() {
        require(_isGelatoRelay(msg.sender), "onlyGelatoRelay");
        _;
    }

    function _isGelatoRelay(address _forwarder) internal view returns (bool) {
        if (_forwarder == _gelatoRelay) {
            return true;
        }
        return false;
    }
}
