# ASUS Transformer Book T100T — Debian 13 (Trixie) Setup

A practical setup guide and automated script for running **Debian 13 (Trixie)** on the **ASUS Transformer Book T100T** (Intel Atom Bay Trail, 2 GB RAM, 32 GB eMMC storage), focused on hardware drivers, system stability, storage conservation, and known hardware quirks.

---

## Quick Copy & Run

### Option 1: Run a Downloaded Script
```bash
chmod +x t100t-debian13-setup-v2.sh && ./t100t-debian13-setup-v2.sh
```

### Option 2: Download & Run Directly from GitHub
*(Replace `YOUR-USERNAME` and `YOUR-REPO` with your actual GitHub username and repository name.)*
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/t100t-debian13-setup-v2.sh -o t100t-debian13-setup-v2.sh && chmod +x t100t-debian13-setup-v2.sh && ./t100t-debian13-setup-v2.sh
```

Press **Enter** when prompted at the end to reboot and apply the new kernel parameter and drivers.

---

## Post-Reboot Verification (Copy & Paste)

After logging back in, run this single command to check Wi-Fi, audio, kernel boot flags, and remaining storage:
```bash
nmcli device && aplay -l && grep cstate /proc/cmdline && df -h /
```

- **Wi-Fi:** Look for your wireless interface (`wlan0`) under `nmcli device`.
- **Audio:** Look for the `bytcr-rt5640` sound card under `aplay -l`.
- **Kernel Parameter:** Confirm `intel_idle.max_cstate=1` appears in `/proc/cmdline`.
- **Storage:** Check `Avail` under `df -h /` to monitor free space on your 32 GB drive.

---

## Hardware Overview & Known Limitations

| Component | Status on Debian 13 | Notes / Workarounds |
| :--- | :--- | :--- |
| **Wi-Fi & Bluetooth** | Supported | Requires `firmware-brcm80211`, `bluez`, `bluez-firmware`, and Broadcom NVRAM files from EFI. |
| **Speakers & Audio (`bytcr-rt5640`)** | Supported | Requires `firmware-intel-sound`, `alsa-ucm-conf`, `alsa-utils`, and `pipewire-audio`. |
| **Display & Auto-Rotation** | Supported | Intel Bay Trail graphics with `i965-va-driver` and `iio-sensor-proxy`. |
| **Keyboard Dock & Touchpad** | Supported | Works out of the box; basic multi-finger or palm rejection behavior may vary. |
| **Built-in Front Webcam** | **Unsupported** | Uses an Intel Atom ISP (`atomisp`) pipeline without mainline Linux support. Use a UVC USB webcam or an Android camera app (such as `scrcpy` or DroidCam) as a workaround. |
| **Deep Sleep / Suspend (`S3`)** | **Unreliable** | Waking from suspend can freeze on Bay Trail devices. Prefer locking the screen, hibernating, or shutting down. |
| **Micro-HDMI Audio** | **Hit-or-Miss** | Video output generally works; HDMI audio routing may require manual `alsamixer` adjustments. |

---

## Installation Tips for 32 GB Storage & 2 GB RAM

1. **Choose a Lightweight Desktop Environment:** During Debian 13 installation (`tasksel`), select **Xfce** rather than heavier desktop environments such as GNOME to keep RAM usage low and preserve space on the 32 GB eMMC drive.
2. **Standard System Utilities:** If you skipped `standard system utilities` during installation to save space, you can install them later via:
```bash
sudo apt update && sudo apt install -y ~pstandard
```
3. **Expect Longer Install Times on eMMC:** Installation and `initramfs` generation on Atom Bay Trail + eMMC storage can take roughly 15–35 minutes depending on your media and connection speed.

---

## What the Setup Script Does

1. **Enables Required Repositories:** Configures `main contrib non-free non-free-firmware` in APT sources (`/etc/apt/sources.list` and/or `/etc/apt/sources.list.d/debian.sources`).
2. **Installs Utilities & Drivers:** Installs `~pstandard` utilities and space-conscious (`--no-install-recommends`) packages for Wi-Fi, Bluetooth, audio, Intel microcode, VA-API video acceleration, and sensor support.
3. **Copies Wi-Fi NVRAM:** Extracts EFI NVRAM data (when present) into `/lib/firmware/brcm/` for Broadcom SDIO Wi-Fi chips.
4. **Applies Anti-Freeze Kernel Parameter:** Adds `intel_idle.max_cstate=1` to `GRUB_CMDLINE_LINUX_DEFAULT` and updates GRUB to mitigate Bay Trail C-state hangs.
5. **Cleans APT Cache:** Runs `apt clean` and reports remaining root disk space before prompting to reboot.
