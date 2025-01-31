// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

abstract contract GelatoRelayContractsUtils {
    bool internal immutable _isV1ChainId;
    bool internal immutable _isV1ZkSyncChainId;
    bool internal immutable _isV2ZkSyncChainId;

    constructor() {
        _isV1ChainId = __isV1ChainId(block.chainid);
        _isV1ZkSyncChainId = __isV1ZkSyncChainId(block.chainid);
        _isV2ZkSyncChainId = __isV2ZkSyncChainId(block.chainid);
    }

    // solhint-disable-next-line function-max-lines
    function __isV1ChainId(uint256 chainId) private pure returns (bool) {
        if (
            chainId == 1 ||
            chainId == 10 ||
            chainId == 25 ||
            chainId == 30 ||
            chainId == 56 ||
            chainId == 100 ||
            chainId == 109 ||
            chainId == 137 ||
            chainId == 183 ||
            chainId == 233 ||
            chainId == 250 ||
            chainId == 314 ||
            chainId == 1088 ||
            chainId == 1101 ||
            chainId == 1135 ||
            chainId == 1284 ||
            chainId == 1285 ||
            chainId == 1729 ||
            chainId == 1829 ||
            chainId == 1833 ||
            chainId == 2039 ||
            chainId == 3776 ||
            chainId == 4202 ||
            chainId == 6398 ||
            chainId == 8453 ||
            chainId == 10200 ||
            chainId == 18231 ||
            chainId == 18233 ||
            chainId == 25327 ||
            chainId == 34443 ||
            chainId == 41455 ||
            chainId == 42069 ||
            chainId == 42161 ||
            chainId == 43114 ||
            chainId == 59144 ||
            chainId == 80002 ||
            chainId == 80084 ||
            chainId == 81457 ||
            chainId == 84532 ||
            chainId == 111188 ||
            chainId == 241120 ||
            chainId == 421614 ||
            chainId == 656476 ||
            chainId == 1261120 ||
            chainId == 6038361 ||
            chainId == 7777777 ||
            chainId == 11155111 ||
            chainId == 11155420 ||
            chainId == 29313331 ||
            chainId == 69658185 ||
            chainId == 89346162 ||
            chainId == 94204209 ||
            chainId == 123420111 ||
            chainId == 168587773 ||
            chainId == 222000222 ||
            chainId == 994873017 ||
            chainId == 1380012617 ||
            chainId == 3155399334 ||
            chainId == 80998896642 ||
            chainId == 88153591557
        ) {
            return true;
        } else {
            return false;
        }
    }

    function __isV1ZkSyncChainId(uint256 chainId) private pure returns (bool) {
        if (chainId == 324 || chainId == 280) {
            return true;
        }
        return false;
    }

    function __isV2ZkSyncChainId(uint256 chainId) private pure returns (bool) {
        if (chainId == 11124 || chainId == 2741) {
            return true;
        }
        return false;
    }
}
