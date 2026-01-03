#!/bin/bash
# =============================================================================
#  WSL Ubuntu Clone Automation Script
# =============================================================================
#  Author: Ahmed Ameen Mazen Tayeb
#  Project: VelocityPilot (Automation DevOps Scripts)
#  Repository: https://github.com/amazen333/violcityPilot
#
#  Purpose:
#    Automates creation of multiple WSL2 clones from a base Ubuntu/Debian distro.
#    Each clone is imported with systemd enabled, a default user configured,
#    and optionally a setup script applied (e.g., Kubernetes worker bootstrap).
#
#  Features:
#    - Exports a base WSL distro to tarball
#    - Imports multiple clones with unique names and paths
#    - Ensures required folders exist before operations
#    - Optionally copies setup scripts into each clone
#    - Informational ROLE tag for Master/Worker designation
#
#  Usage:
#    Edit parameters as needed, then run:
#      ./wsl-clone.sh
#
#  Notes:
#    - Tested on Windows 11 with WSL2 and Ubuntu 22.04/24.04 LTS
#    - Clones are imported under INSTALL_ROOT with unique names
#    - After import, run: wsl -d <CloneName> to launch each clone
#
#  License: MIT (adapt as needed for project branding)
# =============================================================================


# --- set stricts
set -euo pipefail

# --- Parameters (edit as needed) ----------------------------------------
BASE_DISTRO="Ubuntu-22.04"          # Name of base WSL distro
CLONE_PREFIX="Ubuntu-Clone"         # Prefix for clone names
CLONE_COUNT=3                       # Number of clones to create
IMAGE_PATH="/mnt/c/WSL/images"      # Path to store exported tarball
INSTALL_ROOT="/mnt/c/WSL"           # Root folder for clones
DEFAULT_USER="devops"               # Default user inside distro
ROLE="Master | Worker"              # Informational tag (Master/Worker)
SETUP_SCRIPT_PATH="/mnt/c/repos/k8s/ubuntu-worker.sh"  # Optional setup script
# -----------------------------------------------------------------------------
# --- Ensure folders exist ---
mkdir -p "$IMAGE_PATH" "$INSTALL_ROOT"

# --- Export base distro ---
TAR_FILE="$IMAGE_PATH/${BASE_DISTRO}.tar"
echo "==> Exporting $BASE_DISTRO to $TAR_FILE..."
wsl --export "$BASE_DISTRO" "$TAR_FILE"

# --- Import clones ---
for i in $(seq 1 "$CLONE_COUNT"); do
    CLONE_NAME="${CLONE_PREFIX}${i}"
    CLONE_PATH="$INSTALL_ROOT/$CLONE_NAME"
    echo "==> Importing clone $CLONE_NAME..."
    mkdir -p "$CLONE_PATH"
    wsl --import "$CLONE_NAME" "$CLONE_PATH" "$TAR_FILE" --version 2

    # Optional: copy setup script into clone
    if [ -f "$SETUP_SCRIPT_PATH" ]; then
        echo "==> Copying setup script into $CLONE_NAME..."
        cp "$SETUP_SCRIPT_PATH" "$CLONE_PATH/"
    fi
done

echo "✅ $CLONE_COUNT clones of $BASE_DISTRO created successfully."
echo "ℹ️  Use: wsl -d <CloneName> to launch each clone."
