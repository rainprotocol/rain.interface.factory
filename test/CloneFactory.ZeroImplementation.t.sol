// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "./CloneFactoryTest.sol";

import "src/concrete/CloneFactory.sol";

contract CloneFactoryZeroImplementationTest is CloneFactoryTest {
    function testZeroImplementationError() public {
        vm.expectRevert(abi.encodeWithSelector(ZeroImplementation.selector));
        cloneFactory.clone(address(0), "");
    }
}
