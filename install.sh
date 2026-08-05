#!/bin/bash
set -e

echo "=========================================================="
echo " Realtek RTL8189FTV / RTL8189FS SDIO Wi-Fi Driver Installer"
echo " Target SBC: ZTE B860H, HG680P, Amlogic S905X / Armbian"
echo "=========================================================="

KERNEL_VER=$(uname -r)
PREBUILT_DIR="prebuilt/${KERNEL_VER}"
TARGET_MODULE_DIR="/lib/modules/${KERNEL_VER}/kernel/drivers/net/wireless/realtek/rtl8189fs"

echo "[i] Current Kernel Version: ${KERNEL_VER}"

if [ -f "${PREBUILT_DIR}/8189fs.ko" ]; then
    echo "[+] Found matching prebuilt module for kernel ${KERNEL_VER}!"
    read -p "Do you want to use the prebuilt binary? (Y/n): " CHOICE
    CHOICE=${CHOICE:-Y}
    if [[ "$CHOICE" =~ ^[Yy]$ ]]; then
        echo "[*] Installing prebuilt module..."
        sudo mkdir -p "${TARGET_MODULE_DIR}"
        sudo cp "${PREBUILT_DIR}/8189fs.ko" "${TARGET_MODULE_DIR}/"
        sudo depmod -a
        sudo modprobe 8189fs
        echo "[✓] Prebuilt driver loaded successfully!"
        echo "    Run 'ip link' or 'nmcli dev wifi' to check your wireless interface."
        exit 0
    fi
fi

echo "[*] Building driver from source code for kernel ${KERNEL_VER}..."
echo "[*] Checking & installing build dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential linux-headers-${KERNEL_VER} git || sudo apt-get install -y build-essential linux-headers-ophub git || true

echo "[*] Compiling 8189fs kernel module..."
make clean || true
make -j$(nproc) ARCH=arm64 KSRC=/lib/modules/${KERNEL_VER}/build

echo "[*] Installing compiled module into system..."
sudo mkdir -p "${TARGET_MODULE_DIR}"
sudo cp 8189fs.ko "${TARGET_MODULE_DIR}/"
sudo depmod -a
sudo modprobe 8189fs

echo "[✓] Driver built and loaded successfully!"
echo "    Check interface status with: ip link show wlan1"
