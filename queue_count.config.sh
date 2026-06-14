#!/usr/bin/env bash

# Edit these values to change the menu bar text and connection settings.

# ComfyUI address
QUEUE_COUNT_BASE_URL="http://127.0.0.1:8188"

# Menu bar text
QUEUE_COUNT_TEXT_BEFORE="Queue: "
QUEUE_COUNT_TEXT_AFTER_SINGULAR=" image left"
QUEUE_COUNT_TEXT_AFTER_PLURAL=" images left"

# Offline / error text
QUEUE_COUNT_ERROR_TEXT="ComfyUI offline"

# Count behavior
# true  = include the currently running prompt in the count
# false = only count items still waiting in the queue
QUEUE_COUNT_INCLUDE_RUNNING="true"

# How long each queue check waits for ComfyUI to respond before giving up.
# This does not control how often SwiftBar refreshes the plugin.
# Example: "2" means each check waits up to 2 seconds for a response.
QUEUE_COUNT_TIMEOUT_SECONDS="2"
