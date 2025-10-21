let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  packages = [
    pkgs.age
    pkgs.nixos-anywhere
    pkgs.opentofu
    pkgs.sops
    pkgs.yq
  ];
}
