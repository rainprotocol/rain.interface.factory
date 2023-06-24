// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "forge-std/Test.sol";

import "rain.interpreter/abstract/DeployerDiscoverableMetaV1.sol";
import {CloneFactory} from "src/concrete/CloneFactory.sol";

contract CloneFactoryTest is Test {
    CloneFactory immutable cloneFactory;

    constructor() {
        address deployer = address(uint160(uint256(keccak256("deployer"))));
        vm.etch(deployer, hex"00");
        bytes memory meta = vm.readFileBinary("meta/CloneFactory.rain.meta");
        vm.mockCall(deployer, "", abi.encode(address(0), address(0), address(0)));
        vm.expectCall(address(deployer), abi.encodeWithSelector(IExpressionDeployerV1.deployExpression.selector));
        cloneFactory = new CloneFactory(DeployerDiscoverableMetaV1ConstructionConfig(deployer, meta));
    }
}
