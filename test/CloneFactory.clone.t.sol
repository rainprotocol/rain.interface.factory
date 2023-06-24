// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "./CloneFactoryTest.sol";

import "src/concrete/CloneFactory.sol";

bytes constant EIP1167_PREFIX = hex"363d3d373d3d3d363d73";
bytes constant EIP1167_SUFFIX = hex"5af43d82803e903d91602b57fd5bf3";

contract TestCloneable is ICloneableV1 {
    bytes public sData;

    function initialize(bytes memory data) external {
        sData = data;
    }
}

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
}
