#!/usr/bin/env bash
# <xbar.title>ComfyUI Queue Count</xbar.title>
# <xbar.version>v0.1.0</xbar.version>
# <xbar.author>comfy-queue-count contributors</xbar.author>
# <xbar.desc>Menu bar queue counter for ComfyUI with customizable singular/plural labels.</xbar.desc>
# <xbar.dependencies>bash,python3</xbar.dependencies>

set -u

SOURCE_PATH="${BASH_SOURCE[0]}"
while [ -L "$SOURCE_PATH" ]; do
  SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE_PATH")" && pwd)"
  SOURCE_PATH="$(readlink "$SOURCE_PATH")"
  [[ "$SOURCE_PATH" != /* ]] && SOURCE_PATH="$SCRIPT_DIR/$SOURCE_PATH"
done

SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE_PATH")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HELPER_PATH="$REPO_DIR/scripts/queue_count.py"
CONFIG_PATH="$REPO_DIR/queue_count.config.sh"

if [ -f "$CONFIG_PATH" ]; then
  # shellcheck disable=SC1090
  source "$CONFIG_PATH"
fi

BASE_URL="${COMFYUI_BASE_URL:-${QUEUE_COUNT_BASE_URL:-http://127.0.0.1:8188}}"
TEXT_BEFORE="${COUNT_TEXT_BEFORE:-${QUEUE_COUNT_TEXT_BEFORE:-Queue: }}"
TEXT_AFTER_SINGULAR="${COUNT_TEXT_AFTER_SINGULAR:-${QUEUE_COUNT_TEXT_AFTER_SINGULAR:- image left}}"
TEXT_AFTER_PLURAL="${COUNT_TEXT_AFTER_PLURAL:-${QUEUE_COUNT_TEXT_AFTER_PLURAL:- images left}}"
ERROR_TEXT="${COUNT_ERROR_TEXT:-${QUEUE_COUNT_ERROR_TEXT:-ComfyUI offline}}"
INCLUDE_RUNNING="${COUNT_INCLUDE_RUNNING:-${QUEUE_COUNT_INCLUDE_RUNNING:-true}}"
TIMEOUT_SECONDS="${COUNT_TIMEOUT_SECONDS:-${QUEUE_COUNT_TIMEOUT_SECONDS:-2}}"

python3 "$HELPER_PATH" \
  --base-url "$BASE_URL" \
  --timeout "$TIMEOUT_SECONDS" \
  --text-before "$TEXT_BEFORE" \
  --text-after-singular "$TEXT_AFTER_SINGULAR" \
  --text-after-plural "$TEXT_AFTER_PLURAL" \
  --error-text "$ERROR_TEXT" \
  --include-running="$INCLUDE_RUNNING" \
  --menu
