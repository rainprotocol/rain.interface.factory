// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "../interface/ICloneableV1.sol";
import "../interface/ICloneableFactoryV1.sol";
import "rain.interpreter/abstract/DeployerDiscoverableMetaV1.sol";
import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";

/// Thrown when an implementation is the zero address which is always a mistake.
error ZeroImplementation();

bytes32 constant CLONE_FACTORY_META_HASH = bytes32(0xd579a9e360906d024897f32ca8d782c645163dad24894843cfe11fbdc0742d55);

contract CloneFactory is ICloneableFactoryV1, DeployerDiscoverableMetaV1 {
    constructor(DeployerDiscoverableMetaV1ConstructionConfig memory config_)
        DeployerDiscoverableMetaV1(CLONE_FACTORY_META_HASH, config_)
    {}

    /// @inheritdoc ICloneableFactoryV1
    function clone(address implementation, bytes calldata data) external returns (address) {
        if (implementation == address(0)) {
            revert ZeroImplementation();
        }
        address child = Clones.clone(implementation);
        emit NewClone(msg.sender, implementation, child);
        ICloneableV1(child).initialize(data);
        return child;
    }
}
