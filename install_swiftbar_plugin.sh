#!/usr/bin/env bash

set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]}"
while [ -L "$SOURCE_PATH" ]; do
  SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE_PATH")" && pwd)"
  SOURCE_PATH="$(readlink "$SOURCE_PATH")"
  [[ "$SOURCE_PATH" != /* ]] && SOURCE_PATH="$SCRIPT_DIR/$SOURCE_PATH"
done

REPO_DIR="$(cd -P "$(dirname "$SOURCE_PATH")" && pwd)"
PLUGIN_SOURCE="$REPO_DIR/swiftbar/comfy-queue-count.5s.sh"
HELPER_SOURCE="$REPO_DIR/scripts/queue_count.py"
CONFIG_EXAMPLE_SOURCE="$REPO_DIR/queue_count.config.sh.example"
CONFIG_TARGET="$REPO_DIR/queue_count.config.sh"
PLUGINS_DIR="${SWIFTBAR_PLUGINS_DIR:-$HOME/Library/Application Support/SwiftBar/Plugins}"
PLUGIN_TARGET="$PLUGINS_DIR/comfy-queue-count.5s.sh"

if [ ! -f "$PLUGIN_SOURCE" ]; then
  echo "Could not find SwiftBar plugin at:"
  echo "  $PLUGIN_SOURCE"
  exit 1
fi

if [ ! -f "$HELPER_SOURCE" ]; then
  echo "Could not find helper script at:"
  echo "  $HELPER_SOURCE"
  exit 1
fi

if [ ! -f "$CONFIG_EXAMPLE_SOURCE" ]; then
  echo "Could not find config example at:"
  echo "  $CONFIG_EXAMPLE_SOURCE"
  exit 1
fi

chmod +x "$PLUGIN_SOURCE" "$HELPER_SOURCE"
mkdir -p "$PLUGINS_DIR"

if [ ! -f "$CONFIG_TARGET" ]; then
  cp "$CONFIG_EXAMPLE_SOURCE" "$CONFIG_TARGET"
fi

if [ -L "$PLUGIN_TARGET" ]; then
  EXISTING_TARGET="$(readlink "$PLUGIN_TARGET" || true)"
  if [ "$EXISTING_TARGET" = "$PLUGIN_SOURCE" ]; then
    cat <<EOF
SwiftBar plugin is already installed.

Plugin source:
  $PLUGIN_SOURCE

Plugin target:
  $PLUGIN_TARGET

Next steps:
1. In SwiftBar, make sure your plugins folder is set to:
   $PLUGINS_DIR
2. Refresh SwiftBar.
3. Look for a menu bar label like:
   Queue: 0 images left
EOF
    exit 0
  fi
fi

if [ -e "$PLUGIN_TARGET" ] || [ -L "$PLUGIN_TARGET" ]; then
  if ! rm -f "$PLUGIN_TARGET"; then
    cat <<EOF
Could not replace the existing plugin target:
  $PLUGIN_TARGET

Please remove it manually, then run this script again.

If you want to inspect the current target, run:
  ls -l "$PLUGIN_TARGET"
EOF
    exit 1
  fi
fi

ln -s "$PLUGIN_SOURCE" "$PLUGIN_TARGET"

cat <<EOF
SwiftBar plugin installed.

Plugin source:
  $PLUGIN_SOURCE

Plugin target:
  $PLUGIN_TARGET

Config file:
  $CONFIG_TARGET

Next steps:
1. In SwiftBar, make sure your plugins folder is set to:
   $PLUGINS_DIR
2. Refresh SwiftBar.
3. To change the label text later, edit:
   $CONFIG_TARGET
4. Look for a menu bar label like:
   Queue: 0 images left
EOF
