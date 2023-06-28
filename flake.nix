{
  description = "Flake for development workflows.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rain.url = "github:rainprotocol/rain.cli";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {self, nixpkgs, rain, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rain-cli = "${rain.defaultPackage.${system}}/bin/rain";

      in rec {
        packages = rec {
          build-meta = pkgs.writeShellScriptBin "build-meta" ''
            forge build && \
            ${rain-cli} meta build -o meta/CloneFactory.rain.meta -i <(${rain-cli} meta solc artifact -c abi -i out/CloneFactory.sol/CloneFactory.json) -m solidity-abi-v2 -t json -e deflate -l en
          '';

          default = build-meta;
        };
      }
    );

}
