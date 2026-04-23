#!/bin/bash
# Enable Network Security - Disable Bonjour, Captive Portal, restrict AirDrop
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/5] Disabling Bonjour multicast advertising..."
defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true

echo "[2/5] Disabling Captive Portal assistant..."
defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool false

echo "[3/5] Restricting AirDrop to contacts only..."
defaults write com.apple.sharingd DiscoverableMode -string "Contacts Only"

echo "[4/5] Disabling Wake on Network Access..."
pmset -a womp 0

echo "[5/5] Disabling Bluetooth Sharing..."
defaults -currentHost write com.apple.Bluetooth PrefKeyServicesEnabled -bool false

echo "[OK] Network Security Enabled"
