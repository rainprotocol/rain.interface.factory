// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @title ICloneableV1
/// @notice Minimal interface following the Open Zeppelin conventions for
/// initializing a cloned proxy. To be fully generic the initilize accepts
/// `bytes` and so MUST abi decode within the initialize function. This allows
/// the factory to service arbitrary cloneable proxies but also erases the type
/// of the initialization config from the ABI. One workaround is to emit an event
/// containing the initialization config type, so that the type appears within
/// the event and therefore the ABI.
interface ICloneableV1 {
    /// Initialize is intended to work
    function initialize(bytes calldata data) external;
}
