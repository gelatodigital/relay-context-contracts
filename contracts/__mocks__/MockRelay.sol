// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {GelatoBytes} from "../lib/GelatoBytes.sol";

/// @dev Mock contracts for testing - UNSAFE CODE - do not copy
contract MockRelay {
    using GelatoBytes for bytes;

    function forwardCall(address _target, bytes calldata _data) external {
        (bool success, bytes memory returndata) = _target.call(_data);
        if (!success) returndata.revertWithError("MockRelay.forwardCall:");
    }
}
