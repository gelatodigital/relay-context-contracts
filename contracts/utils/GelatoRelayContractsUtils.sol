// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract GelatoRelayContractsUtils {
    mapping(uint256 => bool) internal _v1ChainIds;

    // solhint-disable-next-line function-max-lines
    constructor() {
        _v1ChainIds[1] = true;
        _v1ChainIds[10] = true;
        _v1ChainIds[25] = true;
        _v1ChainIds[30] = true;
        _v1ChainIds[56] = true;
        _v1ChainIds[100] = true;
        _v1ChainIds[109] = true;
        _v1ChainIds[137] = true;
        _v1ChainIds[183] = true;
        _v1ChainIds[233] = true;
        _v1ChainIds[250] = true;
        _v1ChainIds[314] = true;
        _v1ChainIds[1088] = true;
        _v1ChainIds[1101] = true;
        _v1ChainIds[1135] = true;
        _v1ChainIds[1284] = true;
        _v1ChainIds[1285] = true;
        _v1ChainIds[1729] = true;
        _v1ChainIds[1829] = true;
        _v1ChainIds[1833] = true;
        _v1ChainIds[2039] = true;
        _v1ChainIds[3776] = true;
        _v1ChainIds[4202] = true;
        _v1ChainIds[6398] = true;
        _v1ChainIds[8453] = true;
        _v1ChainIds[10200] = true;
        _v1ChainIds[18231] = true;
        _v1ChainIds[18233] = true;
        _v1ChainIds[25327] = true;
        _v1ChainIds[34443] = true;
        _v1ChainIds[41455] = true;
        _v1ChainIds[42069] = true;
        _v1ChainIds[42161] = true;
        _v1ChainIds[43114] = true;
        _v1ChainIds[59144] = true;
        _v1ChainIds[80002] = true;
        _v1ChainIds[80002] = true;
        _v1ChainIds[80084] = true;
        _v1ChainIds[81457] = true;
        _v1ChainIds[84532] = true;
        _v1ChainIds[111188] = true;
        _v1ChainIds[241120] = true;
        _v1ChainIds[421614] = true;
        _v1ChainIds[656476] = true;
        _v1ChainIds[1261120] = true;
        _v1ChainIds[6038361] = true;
        _v1ChainIds[7777777] = true;
        _v1ChainIds[11155111] = true;
        _v1ChainIds[11155420] = true;
        _v1ChainIds[29313331] = true;
        _v1ChainIds[69658185] = true;
        _v1ChainIds[89346162] = true;
        _v1ChainIds[94204209] = true;
        _v1ChainIds[123420111] = true;
        _v1ChainIds[168587773] = true;
        _v1ChainIds[222000222] = true;
        _v1ChainIds[994873017] = true;
        _v1ChainIds[1380012617] = true;
        _v1ChainIds[3155399334] = true;
        _v1ChainIds[80998896642] = true;
        _v1ChainIds[88153591557] = true;
    }

    function isV1ChainId(uint256 chainId) public view returns (bool) {
        return _v1ChainIds[chainId];
    }

    function isZkSyncChainId(uint256 chainId) public pure returns (bool) {
        if (chainId == 324 || chainId == 280) {
            return true;
        }
        return false;
    }
}
