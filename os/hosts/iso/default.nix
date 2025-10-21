{
  pkgs,
  lib,
  ...
}:
{
  imports = [
  ];

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    extraOptions = "experimental-features = nix-command flakes";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [
      "ehci_pci"
      "ahci"
      "xhci_pci_renesas"
      "nvme"
      "uas"
      "usbhid"
      "sd_mod"
    ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      systemd-boot = {
        enable = true;
      };
    };
  };

  networking = {
    hostName = "iso";
  };

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJKcUwPKD4XVY/CD36DrBhlQkUq3AzKaNpfHb0S5ZqQB"
  ];

  isoImage = {
    squashfsCompression = "gzip -Xcompression-level 1";
  };
}
