#!/bin/bash
# Disable Privacy Security - Restore default privacy settings
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/5] Enabling Apple Analytics sharing..."
defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool true
defaults write com.apple.CrashReporter DialogType -string "crashreport"

echo "[2/5] Enabling personalized ads..."
defaults write com.apple.AdLib forceLimitAdTracking -bool false

echo "[3/5] Enabling Siri analytics..."
defaults write com.apple.assistant.support "Siri Data Sharing Opt-In Status" -int 0

echo "[4/5] Enabling Safari search suggestions..."
defaults write com.apple.Safari UniversalSearchEnabled -bool true
defaults write com.apple.Safari SuppressSearchSuggestions -bool false
defaults write com.apple.Safari PreloadTopHit -bool true

echo "[5/5] Safari fraud warnings remain enabled (safe default)."

echo "[OK] Privacy Security Disabled (defaults restored)"
