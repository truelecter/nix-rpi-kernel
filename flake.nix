{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
  };

  outputs = inputs @ {
    flake-utils,
    nixpkgs,
    ...
  }: let
    lib = nixpkgs.lib // (import ./nix/lib.nix);
  in
    flake-utils.lib.eachSystem [
      "aarch64-linux"
    ] (
      system: let
        pkgs = import nixpkgs {
          inherit system;

          config.allowUnfree = true;
        };
      in {
        packages =
          # latest
          lib.getPackages (import ./nix/versions.nix {})."6.1.63" pkgs;
      }
    )
    // {
      overlays = lib.mapAttrs lib.overlay (import ./nix/versions.nix {});
    };
}
