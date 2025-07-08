// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

abstract contract GelatoRelayERC2771Base {
    address internal immutable _gelatoRelayERC2771;
    address internal immutable _gelatoRelayConcurrentERC2771;

    modifier onlyGelatoRelayERC2771() {
        require(_isGelatoRelayERC2771(msg.sender), "onlyGelatoRelayERC2771");
        _;
    }

    constructor(
        address __gelatoRelayERC2771,
        address __gelatoRelayConcurrentERC2771
    ) {
        require(
            __gelatoRelayERC2771 != address(0),
            "GelatoRelayERC2771Base: GelatoRelayERC2771 cannot be zero address"
        );
        require(
            __gelatoRelayConcurrentERC2771 != address(0),
            "GelatoRelayERC2771Base: GelatoRelayConcurrentERC2771 cannot be zero address"
        );
        _gelatoRelayERC2771 = __gelatoRelayERC2771;
        _gelatoRelayConcurrentERC2771 = __gelatoRelayConcurrentERC2771;
    }

    function _isGelatoRelayERC2771(address _forwarder)
        internal
        view
        returns (bool)
    {
        if (
            _forwarder == _gelatoRelayERC2771 ||
            _forwarder == _gelatoRelayConcurrentERC2771
        ) {
            return true;
        }
        return false;
    }
}
