#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Backup existing bashrc
if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d-%H%M%S)
    echo "Backed up existing .bashrc"
fi

# Create symlink
ln -sf "$SCRIPT_DIR/.bashrc" ~/.bashrc
echo "Created symlink to .bashrc"

source ~/.bashrc
echo "✅ Done! Any changes to the repo will auto-apply."