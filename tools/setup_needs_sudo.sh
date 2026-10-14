#!/usr/bin/env bash
# Steps that need your password / GUI. Already done without sudo:
#   Flutter 3.47.7 (brew cask), Android SDK (~/Library/Android/sdk) + licenses: platform-tools,
#   platforms;android-36, build-tools;36.0.0, emulator, system image, AVD "flutter_pixel".
set -euo pipefail

# 1. Android env vars for your shell (only appended once).
if ! grep -q ANDROID_HOME ~/.zshrc 2>/dev/null; then
  cat >> ~/.zshrc <<'RC'
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
RC
fi

# 2. Android Studio (IDE + Flutter plugin; may ask for your password to write /Applications).
brew install --cask android-studio || true

# 3. Android licenses (already accepted; harmless re-check).
flutter doctor --android-licenses || true

# 4. iOS / macOS builds: install Xcode from the App Store FIRST, then:
if [ -d /Applications/Xcode.app ]; then
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  sudo xcodebuild -license accept
  brew install cocoapods
else
  echo "Xcode not found — install it from the App Store, then re-run this script for iOS support."
fi

flutter doctor
