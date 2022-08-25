// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// import {
//     _encodeRelayerContext,
//     _encodeRelayerContextERC2771
// } from "@gelatonetwork/relayer-context/contracts/RelayerUtils.sol";

// /// @dev Mock contracts for testing - UNSAFE CODE - do not copy
// contract MockRelayer {
//     function forwardCall(
//         address _target,
//         bytes calldata _data,
//         address _feeCollector,
//         address _feeToken,
//         uint256 _fee
//     ) external {
//         (bool success, ) = _target.call(
//             _encodeRelayerFeeContext(_data, _feeCollector, _feeToken, _fee)
//         );
//         require(success, "MockRelayer.forwardCall: reverted");
//     }

//     function forwardCallERC2771(
//         address _target,
//         bytes calldata _data,
//         address _feeCollector,
//         address _feeToken,
//         uint256 _fee,
//         address _user
//     ) external {
//         (bool success, ) = _target.call(
//             _encodeRelayerContextERC2771(
//                 _data,
//                 _feeCollector,
//                 _feeToken,
//                 _fee,
//                 _user
//             )
//         );
//         require(success, "MockRelayer.forwardCallERC2771: reverted");
//     }
// }
