{
  description = "Hardwood Homelab";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/25.05";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    { nixpkgs, disko, ... }:
    let
      homelabConfig = {
      };
    in
    {
      nixosConfigurations = {
        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
            ./hosts/iso
          ];
        };
        ash = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/ash
          ];
          specialArgs = { inherit homelabConfig; };
        };
        cherry = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/cherry
          ];
          specialArgs = { inherit homelabConfig; };
        };
        hickory = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/hickory
          ];
          specialArgs = { inherit homelabConfig; };
        };
        maple = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/maple
          ];
          specialArgs = { inherit homelabConfig; };
        };
      };
    };
}
