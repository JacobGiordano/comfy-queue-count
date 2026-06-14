#!/usr/bin/env python3

import argparse
import json
import sys
import urllib.error
import urllib.request


DEFAULT_BASE_URL = "http://127.0.0.1:8188"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Fetch the current ComfyUI queue count and format it for SwiftBar."
    )
    parser.add_argument(
        "--base-url",
        default=DEFAULT_BASE_URL,
        help="Base URL for your ComfyUI instance.",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=2.0,
        help="HTTP timeout in seconds.",
    )
    parser.add_argument(
        "--text-before",
        default="Queue: ",
        help="Text to render before the count.",
    )
    parser.add_argument(
        "--text-after-singular",
        default=" image left",
        help="Text to render after the count when it equals 1.",
    )
    parser.add_argument(
        "--text-after-plural",
        default=" images left",
        help="Text to render after the count for 0 or values greater than 1.",
    )
    parser.add_argument(
        "--error-text",
        default="ComfyUI offline",
        help="Fallback text when the queue cannot be fetched.",
    )
    parser.add_argument(
        "--include-running",
        type=parse_bool,
        default=True,
        help="Whether to count the currently running prompt as still left in the queue.",
    )
    parser.add_argument(
        "--menu",
        action="store_true",
        help="Emit SwiftBar menu output instead of a single line.",
    )
    return parser.parse_args()


def parse_bool(value):
    if isinstance(value, bool):
        return value
    normalized = value.strip().lower()
    if normalized in {"1", "true", "yes", "on"}:
        return True
    if normalized in {"0", "false", "no", "off"}:
        return False
    raise argparse.ArgumentTypeError(
        "Expected one of: true, false, yes, no, 1, 0, on, off."
    )


def fetch_queue_payload(base_url, timeout):
    url = f"{base_url.rstrip('/')}/queue"
    request = urllib.request.Request(
        url,
        headers={"Accept": "application/json"},
    )
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return json.load(response), url


def list_count(value):
    if isinstance(value, list):
        return len(value)
    if isinstance(value, int):
        return value
    return None


def extract_queue_count(payload, include_running):
    direct_keys = (
        "queue_remaining",
        "queue_size",
        "remaining",
        "queued_remaining",
    )
    for key in direct_keys:
        value = payload.get(key) if isinstance(payload, dict) else None
        if isinstance(value, int):
            return value

    if not isinstance(payload, dict):
        raise ValueError("Queue response was not a JSON object.")

    pending_keys = (
        "queue_pending",
        "pending",
        "queued",
        "queue",
    )
    running_keys = (
        "queue_running",
        "running",
        "current",
    )

    pending_count = None
    for key in pending_keys:
        count = list_count(payload.get(key))
        if count is not None:
            pending_count = count
            break

    running_count = None
    for key in running_keys:
        count = list_count(payload.get(key))
        if count is not None:
            running_count = count
            break

    if pending_count is None and running_count is None:
        raise ValueError("Could not identify queue counts in the /queue response.")

    total = pending_count or 0
    if include_running:
        total += running_count or 0
    return total


def format_count(count, text_before, singular_text, plural_text):
    trailing = singular_text if count == 1 else plural_text
    return f"{text_before}{count}{trailing}"


def build_menu(title, base_url, queue_url, include_running):
    mode = "running + pending" if include_running else "pending only"
    return "\n".join(
        [
            title,
            "---",
            "Refresh | refresh=true",
            f"Open ComfyUI | href={base_url}",
            f"Queue endpoint: {queue_url}",
            f"Counting mode: {mode}",
        ]
    )


def main():
    args = parse_args()

    try:
        payload, queue_url = fetch_queue_payload(args.base_url, args.timeout)
        count = extract_queue_count(payload, args.include_running)
        title = format_count(
            count,
            args.text_before,
            args.text_after_singular,
            args.text_after_plural,
        )
        if args.menu:
            print(build_menu(title, args.base_url, queue_url, args.include_running))
        else:
            print(title)
        return 0
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError, ValueError) as exc:
        if args.menu:
            print(
                "\n".join(
                    [
                        args.error_text,
                        "---",
                        "Refresh | refresh=true",
                        f"Open ComfyUI | href={args.base_url}",
                        f"Error: {exc}",
                    ]
                )
            )
        else:
            print(args.error_text)
        # SwiftBar shows a broken-plugin icon for non-zero exits. Treat
        # expected connectivity issues as a normal rendered state instead.
        return 0


if __name__ == "__main__":
    sys.exit(main())
