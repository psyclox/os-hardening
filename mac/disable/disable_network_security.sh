#!/bin/bash
# Disable Network Security - Restore default network settings
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/5] Enabling Bonjour multicast advertising..."
defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool false

echo "[2/5] Enabling Captive Portal assistant..."
defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool true

echo "[3/5] Setting AirDrop to Everyone..."
defaults write com.apple.sharingd DiscoverableMode -string "Everyone"

echo "[4/5] Enabling Wake on Network Access..."
pmset -a womp 1

echo "[5/5] Enabling Bluetooth Sharing..."
defaults -currentHost write com.apple.Bluetooth PrefKeyServicesEnabled -bool true

echo "[OK] Network Security Disabled (defaults restored)"
