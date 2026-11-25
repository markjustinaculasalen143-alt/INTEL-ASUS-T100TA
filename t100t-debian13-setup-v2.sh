#!/usr/bin/env bash
# ==============================================================================
# ASUS Transformer Book T100T (32GB) - Debian 13 (Trixie) Driver & Utility Setup
# Includes:
#   - Debian 13 contrib, non-free, and non-free-firmware repositories
#   - Standard system utilities (~pstandard)
#   - Space-optimized ASUS T100T drivers (Wi-Fi, Bluetooth, Audio, GPU, Sensors)
#   - Broadcom NVRAM EFI extraction for Wi-Fi
#   - Intel Bay Trail anti-freeze GRUB tweak (intel_idle.max_cstate=1)
# ==============================================================================

set -e

echo "============================================================"
echo "  ASUS T100T Debian 13 Driver & Utility Setup"
echo "============================================================"

# Ask for sudo upfront
sudo -v

echo "[1/5] Enabling Debian 13 contrib, non-free, and non-free-firmware repos..."
sudo bash -c '
    if [ -f /etc/apt/sources.list ]; then
        sed -i -E "s/\bmain\b.*/main contrib non-free non-free-firmware/" /etc/apt/sources.list
    fi
    if [ -f /etc/apt/sources.list.d/debian.sources ]; then
        sed -i -E "s/^Components:.*/Components: main contrib non-free non-free-firmware/" /etc/apt/sources.list.d/debian.sources
    fi
'

echo "[2/5] Updating package lists, installing standard utilities (~pstandard), and installing T100T drivers..."
sudo apt update && sudo apt install -y ~pstandard
sudo apt install -y --no-install-recommends \
    firmware-brcm80211 \
    firmware-intel-sound \
    alsa-ucm-conf \
    alsa-utils \
    bluez \
    bluez-firmware \
    intel-microcode \
    i965-va-driver \
    iio-sensor-proxy \
    pipewire-audio

echo "[3/5] Extracting Broadcom Wi-Fi NVRAM calibration from EFI..."
sudo bash -c '
    mkdir -p /lib/firmware/brcm
    NVRAM=$(ls /sys/firmware/efi/efivars/nvram-* 2>/dev/null | head -n 1)
    if [ -n "$NVRAM" ]; then
        cp "$NVRAM" /lib/firmware/brcm/brcmfmac43241b4-sdio.txt
        cp "$NVRAM" /lib/firmware/brcm/brcmfmac43340-sdio.txt
        echo "  -> NVRAM copied successfully."
    else
        echo "  -> No EFI NVRAM variable found (skipping)."
    fi
'

echo "[4/5] Applying Intel Bay Trail anti-freeze fix (intel_idle.max_cstate=1)..."
sudo bash -c '
    if ! grep -q "intel_idle.max_cstate=1" /etc/default/grub; then
        sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"intel_idle.max_cstate=1 /" /etc/default/grub
    fi
    update-grub
'

echo "[5/5] Cleaning apt cache to free up 32GB storage..."
sudo apt clean

echo ""
echo "============================================================"
echo "  Setup Complete! Remaining disk space:"
df -h /
echo "============================================================"
read -p "Press Enter to reboot now (or Ctrl+C to reboot later)..."
sudo reboot
