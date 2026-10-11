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

            # Define an environment variable that can be seen by packages consuming this one. This
            # points at the slang.so that we build, which can be handed to yosys with
            #
            #    yosys -m $YOSYS_SLANG_MODULE ...
            #
            # That will be visible in the build of a package that consumes yosys-slang, and will
            # also be visible when running 'nix develop' in that package.
            mkdir -p $out/nix-support
            echo "export YOSYS_SLANG_MODULE=\"$out/lib/slang.so\"" >$out/nix-support/setup-hook
          '';
        };
      });
  };
}
