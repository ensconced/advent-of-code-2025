{
  description = "flake for advent of code";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      linuxPkgs = import nixpkgs { system = "x86_64-linux"; };
      darwinPkgs = import nixpkgs { system = "aarch64-darwin"; };
    in
    {
      devShells."x86_64-linux".default = linuxPkgs.mkShell {
        nativeBuildInputs = [
        ];
        buildInputs = [
          linuxPkgs.lua5_4
          linuxPkgs.verible
        ];
      };
      devShells."aarch64-darwin".default = darwinPkgs.mkShell {
        packages = [
          darwinPkgs.lua5_4
          darwinPkgs.verible
        ];
      };
    };
}
