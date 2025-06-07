#!/bin/bash
set -ex

FLUTTER_SDK_INSTALL_DIR="$HOME/flutter"
git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_SDK_INSTALL_DIR"
ORIGINAL_PWD=$(pwd)
cd "$FLUTTER_SDK_INSTALL_DIR"
git fetch --tags
git checkout 3.29.3
cd "$ORIGINAL_PWD"

BASHRC_FILE="/root/.bashrc"
FLUTTER_PATH_EXPORT_LINE="export PATH=\"$FLUTTER_SDK_INSTALL_DIR/bin:\$PATH\""
echo "$FLUTTER_PATH_EXPORT_LINE" >> "$BASHRC_FILE"
export PATH="$FLUTTER_SDK_INSTALL_DIR/bin:$PATH"

flutter precache

# Use your own project name
PROJECT_DIR="/workspace/git2dart_binaries"

cd "$PROJECT_DIR"
flutter pub get
flutter gen-l10n
flutter packages pub run build_runner build --delete-conflicting-outputs