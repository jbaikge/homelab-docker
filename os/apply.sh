#/usr/bin/env bash

ACTION="$1"

if [ -z $ACTION ]; then
    echo "$0 install|update"
    exit 1
fi

HOSTS=(
    ash
    cherry
    hickory
    maple
)

if [ "$ACTION" -eq "install" ]; then
    for HOST in "${HOSTS[@]}"; do
        nixos-anywhere \
            --flake ".#${HOST}" \
            --generate-hardware-config nixos-generate-config ./hosts/${HOST}/hardware-configuration.nix \
            -i ~/.ssh/bandit_root@hardwood.cloud \
            --target-host root@${HOST}.hardwood.cloud
    done
fi

if [ "$ACTION" -eq "update" ]; then
    for HOST in "${HOSTS[@]}"; do
        nixos-rebuild switch \
            --flake ".#${HOST}" \
            --target-host "root@${HOST}.hardwood.cloud"
    done
fi
