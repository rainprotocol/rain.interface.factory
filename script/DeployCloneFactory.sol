// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Script.sol";
import "src/concrete/CloneFactory.sol";

/// @title DeployCloneFactory
/// @notice A script that deploys a CloneFactory. This is intended to be run on
/// every commit by CI to a testnet such as mumbai, then cross chain deployed to
/// whatever mainnet is required, by users.
contract DeployCloneFactory is Script {
    /// We are avoiding using ffi here, instead forcing the script runner to
    /// provide the built metadata. On CI this is achieved by using the rain cli.
    function run(bytes memory meta) external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");
        // @todo pull this from subgraph.
        // hardcoded from CI https://github.com/rainprotocol/rain-protocol/actions/runs/5477330173/jobs/9976193858
        address i9rDeployer = 0xd3870063BCF25d5110aB9df9672a0d5c79C8B2d5;

        console2.log("meta hash:");
        console2.logBytes32(keccak256(meta));

        vm.startBroadcast(deployerPrivateKey);
        CloneFactory cloneFactory = new CloneFactory(DeployerDiscoverableMetaV1ConstructionConfig (
            i9rDeployer,
            meta
        ));
        (cloneFactory);
        vm.stopBroadcast();
    }
}
