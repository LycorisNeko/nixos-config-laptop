#!/usr/bin/env bash
set -e

# ANSI Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}  NixOS One-Click Deployment Script    ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Parse arguments
UPDATE_LOCK=false
ACTION="switch"
IS_INSTALL=false

for arg in "$@"; do
    case "$arg" in
        --update|-u)
            UPDATE_LOCK=true
            ;;
        --install|-i)
            IS_INSTALL=true
            ;;
        switch|boot|test|build)
            ACTION="$arg"
            ;;
        --help|-h)
            echo "Usage: ./install.sh [OPTIONS] [ACTION]"
            echo ""
            echo "Actions:"
            echo "  switch        Build and activate configuration immediately (default)"
            echo "  boot          Build and add configuration to bootloader, but don't activate"
            echo "  test          Build and activate configuration without adding to bootloader"
            echo "  build         Build configuration only without activating"
            echo ""
            echo "Options:"
            echo "  -u, --update  Update flake.lock dependencies before rebuilding"
            echo "  -i, --install Use nixos-install for fresh installation to /mnt (Live ISO mode)"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}[WARNING] Unknown option: $arg, ignoring.${NC}"
            ;;
    esac
done

# 1. Sync or generate hardware-configuration.nix
echo -e "${GREEN}[1/4] Checking hardware configuration...${NC}"
if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    echo -e "  Copying /etc/nixos/hardware-configuration.nix to repository..."
    cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
elif [ -f "/mnt/etc/nixos/hardware-configuration.nix" ]; then
    echo -e "  Copying /mnt/etc/nixos/hardware-configuration.nix (Live ISO target)..."
    cp /mnt/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
elif command -v nixos-generate-config >/dev/null 2>&1; then
    echo -e "  Generating hardware-configuration.nix dynamically via nixos-generate-config..."
    if [ "$IS_INSTALL" = true ] && [ -d "/mnt" ]; then
        sudo nixos-generate-config --root /mnt --show-hardware-config > ./hardware-configuration.nix
    else
        sudo nixos-generate-config --show-hardware-config > ./hardware-configuration.nix
    fi
else
    echo -e "${YELLOW}[WARNING] No system hardware-configuration.nix found and nixos-generate-config not available.${NC}"
    if [ -f "./hardware-configuration.nix" ]; then
        echo -e "  Using existing fallback hardware-configuration.nix in repository."
    else
        echo -e "${RED}[ERROR] No hardware-configuration.nix available, aborting!${NC}"
        exit 1
    fi
fi
echo -e "  Hardware configuration is ready."

# 2. Stage changes to Git (Nix Flakes only recognizes Git-tracked files)
echo -e "${GREEN}[2/4] Staging changes to Git...${NC}"
# Prevent Git dubious ownership errors when running with sudo
git config --global --add safe.directory "$SCRIPT_DIR" 2>/dev/null || true
git add -A
echo -e "  All changes staged."

# 3. Flake lock handling
echo -e "${GREEN}[3/4] Checking Nix Flake lock...${NC}"
if [ "$UPDATE_LOCK" = true ] || [ ! -f "./flake.lock" ]; then
    echo -e "  Updating flake inputs (flake.lock)..."
    nix --extra-experimental-features "nix-command flakes" flake update -v
    git add flake.lock
    echo -e "  Flake lock updated."
else
    echo -e "  Using existing flake.lock (pass --update or -u to update inputs)."
fi

# 4. Rebuild / Install NixOS configuration
echo -e "${GREEN}[4/4] Applying NixOS configuration...${NC}"
if [ "$IS_INSTALL" = true ]; then
    echo -e "  Executing fresh system installation via nixos-install (target: /mnt)..."
    sudo nixos-install --flake .#nixos --root /mnt
else
    echo -e "  Executing nixos-rebuild $ACTION (target: .#nixos)..."
    echo -e "${YELLOW}Notice: Please enter your sudo password if prompted.${NC}"
    sudo nixos-rebuild "$ACTION" --flake .#nixos --show-trace
fi

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}  NixOS Deployment Complete!           ${NC}"
echo -e "${GREEN}=======================================${NC}"
echo -e "You can now reboot into your new environment:"
echo -e "  ${BLUE}systemctl reboot${NC}"
