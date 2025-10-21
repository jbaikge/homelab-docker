# Hardwood Homelab

## Set up the Development Environment

So long as you are already running NixOS on the workstation:

```shell
$ nix-shell
```

## Build the ISO

This takes a little bit to build, mostly during the compression stage at the end. Also this assumes you have Ventoy already installed on the USB drive (/dev/sdc).

```shell
$ nix build '.#nixosConfigurations.iso.config.system.build.isoImage'
$ mkdir -p mnt
$ sudo mount /dev/sdc1 mnt
$ sudo cp result/iso/*.iso
$ sudo umount mnt
```

If you want to get really, ultra, fancy: tell Ventoy to automatically boot from this new ISO file by placing this in `mnt/ventoy/ventoy.json` before unmounting:

```json
{
  "control": [
    { "VTOY_MENU_TIMEOUT": "10" },
    { "VTOY_DEFAULT_IMAGE": "/nixos-minimal-00.00-abcdef.iso" },
    { "VTOY_SECONDARY_TIMEOUT": "10" }
  ]
}
```

## Deploy a Machine

Insert the USB and boot the target machine, after about a minute, you should be able to SSH into the target machine as root with the private key corresponding to the public key in `hosts/iso/configuration.nix`.

Once you verify access, verify the right devices in `lsblk` and then run the following:

```shell
$ nixos-anywhere \
    --flake '.#cherry' \
    --generate-hardware-config nixos-generate-config ./hosts/cherry/hardware-configuration.nix \
    -i ~/.ssh/bandit_root@hardwood.cloud \
    --target-host root@cherry.hardwood.cloud
```

Once the command exits, pull the USB drive from the machine and you should be able to SSH in with the private key corresponding to the public key in `hosts/common/hardwood-cluster.nix`.

## Updates

```shell
$ for HOST in cherry hickory maple; do nixos-rebuild switch --flake ".#${HOST}" --target-host "root@${HOST}.hardwood.cloud"; done
```
