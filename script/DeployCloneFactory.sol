// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "forge-std/Script.sol";
import "src/concrete/CloneFactory.sol";

contract DeployCloneFactory is Script {
    function run(bytes memory meta) external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");
        // @todo pull this from subgraph.
        // hardcoded from CI https://github.com/rainprotocol/rain-protocol/actions/runs/5039345251/jobs/9037426821
        address i9rDeployer = 0xB20DFEdC1b12AA6afA308064998A28531a18C714;

        console2.log("meta hash");
        console.logBytes(bytes.concat(keccak256(meta)));

        vm.startBroadcast(deployerPrivateKey);

        CloneFactory cloneFactory = new CloneFactory(DeployerDiscoverableMetaV1ConstructionConfig (
            i9rDeployer,
            meta
        ));
        (cloneFactory);

        vm.stopBroadcast();
    }
}