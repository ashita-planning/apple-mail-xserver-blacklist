#!/usr/bin/env bash
set -euo pipefail

SCHEME="${SCHEME:-XServerMailBlacklist}"
CONFIGURATION="${CONFIGURATION:-Debug}"

if ! compgen -G "*.xcodeproj" > /dev/null && ! compgen -G "*.xcworkspace" > /dev/null; then
  echo "No Xcode project or workspace found. Create the Xcode project first. See Docs/XCODE_PROJECT_SETUP.md."
  exit 1
fi

xcodebuild \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  test
