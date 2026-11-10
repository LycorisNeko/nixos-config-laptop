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

# 1. Sync hardware-configuration.nix
if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    echo -e "${GREEN}[1/4] Syncing hardware configuration...${NC}"
    cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
    echo -e "  Successfully copied /etc/nixos/hardware-configuration.nix to repository."
else
    echo -e "${YELLOW}[WARNING] /etc/nixos/hardware-configuration.nix not found.${NC}"
    if [ -f "./hardware-configuration.nix" ]; then
        echo -e "  Using existing hardware-configuration.nix in repository."
    else
        echo -e "${RED}[ERROR] No hardware-configuration.nix found, aborting!${NC}"
        exit 1
    fi
fi

# 2. Stage changes to Git (prevents dirty tree warnings during flake update)
echo -e "${GREEN}[2/4] Staging hardware configuration to Git...${NC}"
git add -A
echo -e "  Hardware configuration staged."

# 3. Update Nix Flake inputs (with verbose output, local stage only)
echo -e "${GREEN}[3/4] Updating Nix Flake lock (flake.lock)...${NC}"
nix --extra-experimental-features "nix-command flakes" flake update -v
git add flake.lock
echo -e "  Flake lock updated and staged locally."

# 4. Rebuild and switch NixOS configuration
echo -e "${GREEN}[4/4] Building and applying NixOS configuration...${NC}"
echo -e "${YELLOW}Notice: Please enter your sudo password if prompted.${NC}"
sudo nixos-rebuild switch --flake .#

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}  NixOS Deployment Complete!           ${NC}"
echo -e "${GREEN}=======================================${NC}"
echo -e "You can now reboot into your new environment:"
echo -e "  ${BLUE}systemctl reboot${NC}"
