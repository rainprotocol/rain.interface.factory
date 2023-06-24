// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "./CloneFactoryTest.sol";

import "src/concrete/CloneFactory.sol";

bytes constant EIP1167_PREFIX = hex"363d3d373d3d3d363d73";
bytes constant EIP1167_SUFFIX = hex"5af43d82803e903d91602b57fd5bf3";

/// @title TestCloneable
/// @notice A cloneable contract that implements `ICloneableV2`. Initializes
/// whatever data is passed to `initialize` as `sData`. As `sData` is public,
/// we can easily test that it is set correctly.
contract TestCloneable is ICloneableV2 {
    bytes public sData;

    /// @inheritdoc ICloneableV2
    function initialize(bytes memory data) external returns (bytes32) {
        sData = data;
        return ICLONEABLE_V2_SUCCESS;
    }
}

/// @title TestCloneableFailure
/// @notice A cloneable contract that implements `ICloneableV2` but always
/// fails initialization. Specifically, it returns whatever data is passed to
/// `initialize`, which is expected NOT to be `ICLONEABLE_V2_SUCCESS` for the
/// purposes of testing.
contract TestCloneableFailure is ICloneableV2 {
    /// @inheritdoc ICloneableV2
    function initialize(bytes memory data) external pure returns (bytes32 notSuccess) {
        (notSuccess) = abi.decode(data, (bytes32));
    }
}

/// @title CloneFactoryCloneTest
/// @notice A test suite for `CloneFactory` that tests the `clone` function.
contract CloneFactoryCloneTest is CloneFactoryTest {
    function testCloneBytecode(bytes memory data) external {
        TestCloneable implementation = new TestCloneable();

        address child = cloneFactory.clone(address(implementation), data);
        assertEq(child.code, abi.encodePacked(EIP1167_PREFIX, implementation, EIP1167_SUFFIX));
    }

    function testCloneInitializeData(bytes memory data) external {
        TestCloneable implementation = new TestCloneable();

        address child = cloneFactory.clone(address(implementation), data);
        assertEq(TestCloneable(child).sData(), data);
    }

    function testCloneInitializeEvent(bytes memory data) external {
        TestCloneable implementation = new TestCloneable();

        vm.recordLogs();
        address child = cloneFactory.clone(address(implementation), data);
        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 1);
        assertEq(entries[0].topics[0], bytes32(uint256(keccak256("NewClone(address,address,address)"))));
        assertEq(entries[0].data, abi.encode(address(this), address(implementation), child));
    }

    function testCloneUninitializableFails(address implementation, bytes memory data) external {
        vm.expectRevert();
        cloneFactory.clone(implementation, data);
    }

    function testCloneInitializeFailureFailes(bytes32 notSuccess) external {
        vm.assume(notSuccess != ICLONEABLE_V2_SUCCESS);
        TestCloneableFailure implementation = new TestCloneableFailure();

        vm.expectRevert(abi.encodeWithSelector(InitializationFailed.selector));
        cloneFactory.clone(address(implementation), abi.encode(notSuccess));
    }

    function testZeroImplementationCodeSizeError(address implementation, bytes memory data) public {
        vm.assume(implementation.code.length == 0);
        vm.expectRevert(abi.encodeWithSelector(ZeroImplementationCodeSize.selector));
        cloneFactory.clone(implementation, data);
    }
}
