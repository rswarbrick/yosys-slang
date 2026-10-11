# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
{
  description = "Flake for building yosys-slang";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    self.submodules = true;
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    supportedSystems = [ "x86_64-linux" ];
  in {
    packages = nixpkgs.lib.genAttrs supportedSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        default = pkgs.stdenv.mkDerivation {
          name = "yosys-slang";
          src = self;

          nativeBuildInputs = with pkgs; [
            cmake
          ];

          buildInputs = with pkgs; [
            yosys
          ];

          installPhase = ''
            mkdir -p $out/lib
            cp slang.so $out/lib/slang.so
          '';
        };
      });
  };
}
