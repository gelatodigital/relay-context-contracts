// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

function _encodeGelatoRelayContext(
    bytes calldata _data,
    address _feeCollector,
    address _feeToken,
    uint256 _fee
) pure returns (bytes memory) {
    return abi.encodePacked(_data, abi.encode(_feeCollector, _feeToken, _fee));
}

function _encodeFeeCollector(bytes calldata _data, address _feeCollector)
    pure
    returns (bytes memory)
{
    return abi.encodePacked(_data, _feeCollector);
}
