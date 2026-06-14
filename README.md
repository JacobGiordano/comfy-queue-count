# comfy-queue-count

Tiny menu bar queue counter for ComfyUI using [SwiftBar](https://swiftbar.app/).

It polls ComfyUI's `/queue` endpoint, shows the current count in your macOS menu bar, and lets you customize the text before and after the number with singular/plural handling.

Built with OpenAI Codex.

## What It Looks Like

Default output:

- `Queue: 0 images left`
- `Queue: 1 image left`
- `Queue: 4 images left`

Example custom output:

- `Still cooking: 1 render`
- `Still cooking: 6 renders`

Default offline output:

- `ComfyUI offline`

## Files

- `install_swiftbar_plugin.sh`
- `queue_count.config.sh.example`
- `scripts/queue_count.py`
- `swiftbar/comfy-queue-count.5s.sh`

## Install

1. Install SwiftBar from [swiftbar.app](https://swiftbar.app/) or the GitHub releases page at [github.com/swiftbar/SwiftBar/releases](https://github.com/swiftbar/SwiftBar/releases). If you are not sure which one to use, the official site is the simplest path.
2. Move `SwiftBar.app` into your `/Applications` folder before launching it. This is the normal macOS setup and helps avoid issues from running it directly out of Downloads.
3. Open SwiftBar from `/Applications`. If you want your queue counter to come back automatically after a reboot or login, add SwiftBar to `System Settings > General > Login Items`.
4. Run the installer script. This is the easiest option because it automatically:

- makes both scripts executable
- creates the default SwiftBar plugins folder if it does not exist
- symlinks the plugin into that folder
- creates `queue_count.config.sh` for easy text customization if it does not already exist

If you are not comfortable using Terminal, use these exact steps:

1. Open the `comfy-queue-count` folder in Finder.
2. Open the `Terminal` app on your Mac.
3. In Terminal, type:

```bash
cd 
```

4. After the space following `cd`, drag the `comfy-queue-count` folder from Finder into the Terminal window.
   Terminal will paste the full folder path for you.
5. Press `Return`.
6. Then run:

```bash
chmod +x install_swiftbar_plugin.sh
./install_swiftbar_plugin.sh
```

If it worked, you should see a success message that includes:

- `SwiftBar plugin installed.`
- the plugin source path
- the plugin target path
- the config file path

5. When SwiftBar asks you to choose a plugins folder, use your user plugins directory, not the system-wide one.
   The default folder used by the installer is:

```text
$HOME/Library/Application Support/SwiftBar/Plugins
```

   Notes:

- This is inside your user home folder, not `/Library/Application Support`.
- On macOS, your user `Library` folder may be hidden at first.
- If you do not see it, press `Command + Shift + .` in Finder to show hidden files.
- You can also press `Shift + Command + G` and paste `~/Library/Application Support/SwiftBar/Plugins` directly.

   If you prefer to do the setup manually instead of using the installer, use these commands:

```bash
cd /path/to/comfy-queue-count
chmod +x swiftbar/comfy-queue-count.5s.sh
chmod +x scripts/queue_count.py
mkdir -p "$HOME/Library/Application Support/SwiftBar/Plugins"
ln -s "$(pwd)/swiftbar/comfy-queue-count.5s.sh" "$HOME/Library/Application Support/SwiftBar/Plugins/comfy-queue-count.5s.sh"
```

6. Open or refresh SwiftBar. The plugin should appear in your menu bar automatically and start polling `http://127.0.0.1:8188` by default.

If everything is working, you should see a menu bar label such as:

- `Queue: 0 images left`
- `Queue: 1 image left`
- `Queue: 4 images left`

If you do not see the plugin right away:

- Confirm SwiftBar is pointed at the folder that contains your symlinked plugin.
- Confirm the installer completed without errors.
- Click SwiftBar and refresh all plugins.
- Open the plugin in SwiftBar and check for a script error.
- Make sure ComfyUI is running at `http://127.0.0.1:8188`, or set `COMFYUI_BASE_URL` to match your actual address.

If the plugin shows `ComfyUI offline`:

- The plugin is installed and running, but it could not connect to ComfyUI.
- This usually means ComfyUI is closed, still starting up, or running on a different address than `COMFYUI_BASE_URL`.
- Start by confirming ComfyUI is running and reachable in your browser.
- If your ComfyUI instance is not on the default port or host, set `COMFYUI_BASE_URL` in SwiftBar.

7. Optional: customize the wording by editing `queue_count.config.sh` in the repo root.
   This is the easiest way to change the visible text without digging through SwiftBar settings.

## Manual Install

If you want to skip the installer script, use the manual steps below.

### Manual Install Steps

1. Make the plugin executable:

```bash
cd /path/to/comfy-queue-count
chmod +x swiftbar/comfy-queue-count.5s.sh
chmod +x scripts/queue_count.py
```

2. When SwiftBar asks you to choose a plugins folder, use your user plugins directory, not the system-wide one.
   The correct folder is:

```text
$HOME/Library/Application Support/SwiftBar/Plugins
```

   Notes:

- This is inside your user home folder, not `/Library/Application Support`.
- On macOS, your user `Library` folder may be hidden at first.
- If you do not see it, press `Command + Shift + .` in Finder to show hidden files.
- You can also press `Shift + Command + G` and paste `~/Library/Application Support/SwiftBar/Plugins` directly.

   If the folders do not exist yet, create them in this order:

- `Library/Application Support/SwiftBar`
- `Library/Application Support/SwiftBar/Plugins`

3. Symlink the SwiftBar plugin into that SwiftBar plugins folder:

```bash
cd /path/to/comfy-queue-count
mkdir -p "$HOME/Library/Application Support/SwiftBar/Plugins"
ln -s "$(pwd)/swiftbar/comfy-queue-count.5s.sh" "$HOME/Library/Application Support/SwiftBar/Plugins/comfy-queue-count.5s.sh"
```

## Customization

The easiest customization path is editing `queue_count.config.sh` in the repo root.

If that file does not exist yet, either:

- run `./install_swiftbar_plugin.sh`, or
- copy `queue_count.config.sh.example` to `queue_count.config.sh`

Example config:

```bash
QUEUE_COUNT_TEXT_BEFORE="Still cooking: "
QUEUE_COUNT_TEXT_AFTER_SINGULAR=" render"
QUEUE_COUNT_TEXT_AFTER_PLURAL=" renders"
QUEUE_COUNT_ERROR_TEXT="ComfyUI offline"
```

With that configuration, the menu bar would show:

- `Still cooking: 1 render`
- `Still cooking: 8 renders`

You can also customize these settings through environment variables if you prefer. The plugin supports:

- `COMFYUI_BASE_URL`
- `COUNT_TEXT_BEFORE`
- `COUNT_TEXT_AFTER_SINGULAR`
- `COUNT_TEXT_AFTER_PLURAL`
- `COUNT_ERROR_TEXT`
- `COUNT_INCLUDE_RUNNING`
- `COUNT_TIMEOUT_SECONDS`

## Refresh Rate vs Timeout

There are two separate timing settings in this project:

1. The SwiftBar refresh rate
2. The ComfyUI request timeout

The SwiftBar refresh rate is controlled by the plugin filename:

- `swiftbar/comfy-queue-count.5s.sh`

The `5s` part means SwiftBar reruns the plugin every 5 seconds.

The ComfyUI request timeout is controlled by the config file:

```bash
QUEUE_COUNT_TIMEOUT_SECONDS="2"
```

That `2` means each request will wait up to 2 seconds for ComfyUI to respond before showing the offline/error state.

So the default behavior is:

- check the queue every 5 seconds
- wait up to 2 seconds for each check to respond

### How To Change The Refresh Rate

If you want SwiftBar to refresh more or less often, rename the plugin file in both places:

1. In the repo:

```text
swiftbar/comfy-queue-count.5s.sh
```

2. In your SwiftBar plugins folder:

```text
$HOME/Library/Application Support/SwiftBar/Plugins/comfy-queue-count.5s.sh
```

Examples:

- `comfy-queue-count.2s.sh` = refresh every 2 seconds
- `comfy-queue-count.10s.sh` = refresh every 10 seconds

After renaming the file, refresh or relaunch SwiftBar.

## Counting Behavior

By default, the script counts both:

- the currently running prompt
- everything still pending in the queue

If you only want items still waiting and not the active one, set:

```bash
COUNT_INCLUDE_RUNNING=false
```

## Local Test

You can run the helper directly:

```bash
cd /path/to/comfy-queue-count
python3 scripts/queue_count.py --menu
```

Or with custom text:

```bash
cd /path/to/comfy-queue-count
python3 scripts/queue_count.py \
  --text-before "Still cooking: " \
  --text-after-singular " render" \
  --text-after-plural " renders"
```

## Notes

- This assumes ComfyUI is reachable at `http://127.0.0.1:8188` unless you override it.
- The helper tries a few queue response shapes so it can tolerate small API differences.
- A real macOS WidgetKit widget is possible later, but SwiftBar is the fastest path and updates more naturally for a live queue counter.
