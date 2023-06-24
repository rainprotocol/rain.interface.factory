// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "../interface/ICloneableV2.sol";
import "../interface/ICloneableFactoryV2.sol";
import "rain.interpreter/abstract/DeployerDiscoverableMetaV1.sol";
import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";

/// Thrown when an implementation has zero code size which is always a mistake.
error ZeroImplementationCodeSize();

/// Thrown when initialization fails.
error InitializationFailed();

/// @dev Expected hash of the clone factory rain metadata.
bytes32 constant CLONE_FACTORY_META_HASH = bytes32(0xd579a9e360906d024897f32ca8d782c645163dad24894843cfe11fbdc0742d55);

/// @title CloneFactory
/// @notice A fairly minimal implementation of `ICloneableFactoryV2` and
/// `DeployerDiscoverableMetaV1` that uses Open Zeppelin `Clones` to create
/// EIP1167 clones of a reference bytecode. The reference bytecode MUST implement
/// `ICloneableV2` and MUST NOT assume that it will be deployed by a clone
/// factory.
contract CloneFactory is ICloneableFactoryV2, DeployerDiscoverableMetaV1 {
    constructor(DeployerDiscoverableMetaV1ConstructionConfig memory config)
        DeployerDiscoverableMetaV1(CLONE_FACTORY_META_HASH, config)
    {}

    /// @inheritdoc ICloneableFactoryV2
    function clone(address implementation, bytes calldata data) external returns (address) {
        if (implementation.code.length == 0) {
            revert ZeroImplementationCodeSize();
        }
        address child = Clones.clone(implementation);
        emit NewClone(msg.sender, implementation, child);
        if (ICloneableV2(child).initialize(data) != ICLONEABLE_V2_SUCCESS) {
            revert InitializationFailed();
        }
        return child;
    }
}
