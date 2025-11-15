{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot = {
      enable = true;
    };
  };

  time.timeZone = "America/New_York";

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    firewall.enable = false;
    defaultGateway = "10.100.6.1";
    nameservers = [
      "10.100.6.1"
    ];
  };

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQh27P40G5Z6Dny+pTD8a+kTrGZpYtIU0IcyobhZuDS"
      ];
    };

    jake = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwt0GaEQ9qFE/P7LRLEKqDtMF9zbSFtgO3wLq4XZxyM"
      ];

      isNormalUser = true;
      description = "Jake";
      extraGroups = [ "docker" "wheel" ];
      initialPassword = "hardwood";
    };
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [
    pkgs.curl
    pkgs.git
  ];

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  services = {
    openiscsi = {
      enable = true;
      name = "iqn.2025-08.cloud.hardwood.${config.networking.hostName}";
    };
    openssh = {
      enable = true;
    };
  };

  virtualisation = {
    docker = {
      enable = true;
    };
  };

  system.stateVersion = "25.05";
}
