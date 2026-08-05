# Realtek RTL8189FTV / RTL8189FS SDIO Wi-Fi Driver for Armbian Linux

[![License](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Armbian%20%7C%20Linux%205.x%20%7C%206.x-green.svg)]()
[![Hardware](https://img.shields.io/badge/Hardware-ZTE%20B860H%20%7C%20FiberHome%20HG680P%20%7C%20S905X-orange.svg)]()
[![Release](https://img.shields.io/badge/GitHub-Release%20v1.0.0-brightgreen.svg)](https://github.com/gustiarto/rtl8189fs-armbian/releases/tag/v1.0.0)

A community-maintained out-of-tree Linux kernel driver and prebuilt module repository for the **Realtek RTL8189FTV / RTL8189FS** SDIO Wi-Fi chipset. Optimized for Amlogic TV Box Single Board Computers (SBCs) such as **ZTE ZXV10 B860H (v1 / v2 / v2.1)** and **FiberHome HG680P** running modern Armbian Linux kernels (Linux 5.x and 6.x).

---

## 🌟 Overview & Problem Statement

Many Amlogic S905X TV Box SBCs widely distributed in Indonesia and worldwide (such as ZTE B860H 1GB/2GB and FiberHome HG680P) feature an onboard **Realtek RTL8189FTV / RTL8189FS** SDIO 802.11n Wi-Fi adapter (`SDIO_ID=024C:F179`).

Because Realtek does not maintain `8189fs` in the official mainline Linux kernel source tree, updating Armbian to modern kernels (Linux 5.x / 6.x) often causes the internal Wi-Fi adapter to stop working, forcing users to rely on external USB Wi-Fi dongles or remain stuck on ancient legacy kernels (Linux 3.14).

This repository provides:
1. **Fully patched source code** capable of compiling cleanly on modern ARM64 Linux kernels (including Linux 6.1.x / 6.6.x).
2. **Prebuilt driver modules (`.ko`)** in tree and via [GitHub Releases](https://github.com/gustiarto/rtl8189fs-armbian/releases/tag/v1.0.0) (e.g. `6.1.170-ophub`).
3. **Automated installer script (`install.sh`)** for one-command build and installation.

---

## 📋 Hardware & System Compatibility

- **Chipset**: Realtek RTL8189FTV / RTL8189FS (SDIO 802.11b/g/n 2.4GHz)
- **SDIO Vendor/Device ID**: `0x024c:0xf179`
- **Supported Devices**:
  - ZTE ZXV10 B860H v1 / v2 / v2.1 (Amlogic S905X - 1GB & 2GB RAM)
  - FiberHome HG680P (Amlogic S905X - 1GB & 2GB RAM)
  - Other Amlogic S905X / S905W TV Box SBCs with internal RTL8189FTV/FS
- **Supported Operating Systems**: Armbian 20.x - 26.x (Debian / Ubuntu 22.04 / 24.04 LTS arm64)
- **Tested Kernels**: `Linux 6.1.170-ophub` (and compatible Linux 5.x/6.x ARM64 kernels)

---

## 🔍 Hardware Verification

To verify that your SBC's internal Wi-Fi chip is detected on the SDIO bus, run the following command in terminal:

```bash
cat /sys/bus/sdio/devices/mmc0:0001:1/uevent
```

If your hardware matches, you should see output containing:
```
SDIO_ID=024C:F179
```

---

## 🚀 Quick Start (Automated Installation)

Clone this repository to your Armbian device and run the automated installer:

```bash
git clone https://github.com/gustiarto/rtl8189fs-armbian.git
cd rtl8189fs-armbian
chmod +x install.sh
./install.sh
```

The script will automatically detect your active kernel version:
- If a matching **prebuilt module** is available in `prebuilt/<kernel-version>/8189fs.ko`, it will offer to install it directly without compilation.
- Otherwise, it will fetch the required `linux-headers`, compile the module against your running kernel, install it into `/lib/modules/`, and execute `modprobe 8189fs`.

---

## 📦 Prebuilt Binary Download & Release

Prebuilt binary modules are stored in  as well as published on **[GitHub Releases](https://github.com/gustiarto/rtl8189fs-armbian/releases)**.

If your system runs **Armbian Kernel `6.1.170-ophub`**, you can install the prebuilt binary directly:

### Option A: Install from repository clone
```bash
sudo mkdir -p /lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtl8189fs
sudo cp prebuilt/6.1.170-ophub/8189fs.ko /lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtl8189fs/
sudo depmod -a
sudo modprobe 8189fs
```

### Option B: Download directly from GitHub Release
```bash
wget https://github.com/gustiarto/rtl8189fs-armbian/releases/download/v1.0.0/8189fs-6.1.170-ophub.ko
sudo mkdir -p /lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtl8189fs
sudo cp 8189fs-6.1.170-ophub.ko /lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtl8189fs/8189fs.ko
sudo depmod -a
sudo modprobe 8189fs
```

Verify that the wireless interface has been created:
```bash
ip link show wlan1
```

---

## 🛠️ Manual Compilation Guide

If you prefer to compile manually:

### 1. Install Build Dependencies
```bash
sudo apt update
sudo apt install -y build-essential linux-headers-$(uname -r) git
```

### 2. Compile Module
```bash
make clean
make -j$(nproc) ARCH=arm64 KSRC=/lib/modules/$(uname -r)/build
```

### 3. Install & Load Module
```bash
sudo mkdir -p /lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtl8189fs
sudo cp 8189fs.ko /lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtl8189fs/
sudo depmod -a
sudo modprobe 8189fs
```

---

## 📡 Wireless Connection Setup

Once loaded, bring up the interface and scan for available Wi-Fi networks:

```bash
# Bring up interface
sudo ip link set wlan1 up

# Scan SSIDs using iw
sudo iw dev wlan1 scan | grep -E 'SSID:|signal'

# Connect using NetworkManager
sudo nmcli dev wifi connect "YOUR_SSID" password "YOUR_PASSWORD" ifname wlan1
```

---

## 📄 License & Credits

- Driver Source based on Realtek Linux WLAN driver (`rtl8189fs`), maintained for modern Linux kernels by [jwrdegoede](https://github.com/jwrdegoede/rtl8189ES_linux) and the Armbian community.
- Maintained & packaged for ZTE B860H / HG680P Armbian users by [Gusti Arto](https://github.com/gustiarto).
- License: GNU General Public License v2.0 (GPL-2.0).
