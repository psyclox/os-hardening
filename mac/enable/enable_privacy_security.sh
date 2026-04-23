#!/bin/bash
# Enable Privacy Security - Disable analytics, ads, location services
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/5] Disabling Apple Analytics sharing..."
defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool false
defaults write com.apple.CrashReporter DialogType -string "none"

echo "[2/5] Disabling personalized ads (Limit Ad Tracking)..."
defaults write com.apple.AdLib forceLimitAdTracking -bool true
defaults write com.apple.AdLib personalizedAdsMigrated -bool false

echo "[3/5] Disabling Siri analytics..."
defaults write com.apple.assistant.support "Siri Data Sharing Opt-In Status" -int 2

echo "[4/5] Disabling Safari search suggestions and preloading..."
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
defaults write com.apple.Safari PreloadTopHit -bool false

echo "[5/5] Enabling Safari fraud warnings..."
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

echo "[OK] Privacy Security Enabled"
