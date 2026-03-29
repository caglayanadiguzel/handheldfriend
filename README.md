# HandheldFriend

A World of Warcraft retail addon that automatically switches your Edit Mode UI layout and toggles Action Bars when you move between a handheld device (ROG Ally) and a desktop PC.

## What It Does

- **Detects your device** — uses the connected gamepad as the signal: gamepad present = handheld, no gamepad = PC.
- **Switches Edit Mode layout** — applies the layout you've configured for each mode automatically on login or UI reload.
- **Toggles Action Bars 2–8** — hides them in handheld mode (less clutter on a small screen), shows them in PC mode.
- **Combat-safe** — if you're in combat when a switch is needed, it defers and applies as soon as combat ends.
- **ElvUI-compatible** — applies settings 2 seconds after login so ElvUI's own layout restore runs first.
- **Auto-enables Controller Support** — turns on WoW's built-in gamepad support on login so detection works without manual setup.

## Installation

1. Copy or symlink the `HandheldFriend/` folder to:
   ```
   <WoW Install>\_retail_\Interface\AddOns\HandheldFriend\
   ```
2. Log in to WoW. The addon loads automatically.
3. Open **Options → AddOns → HandheldFriend** and assign your Edit Mode layouts for each mode.

## Configuration

Open the in-game panel at **Options → AddOns → HandheldFriend** to set:

| Setting | Description |
|---|---|
| Handheld Layout | Edit Mode preset to activate when a gamepad is connected |
| PC Layout | Edit Mode preset to activate when no gamepad is connected |

Layouts are populated from your saved Edit Mode presets — create them first in Edit Mode, then select them here.

## Slash Commands

| Command | Effect |
|---|---|
| `/handheld` | Show help |
| `/handheld auto` | Auto-detect mode via gamepad (default) |
| `/handheld handheld` | Force handheld mode |
| `/handheld pc` | Force PC mode |
| `/handheld apply` | Re-apply current settings immediately |
| `/handheld debug` | Print detected device, layout, and mode info |

## Requirements

- **WoW Retail** (The War Within, patch 11.0.7+)
- A saved Edit Mode preset for each mode you want to switch between
- ROG Ally (or any gamepad-equipped device) for auto-detection

## How Detection Works

In **auto** mode the addon calls `C_GamePad.GetAllDeviceIDs()` on login. If any gamepad is connected, it activates the handheld layout and hides Action Bars 2–8. If no gamepad is found, it activates the PC layout and shows all Action Bars.

You can override detection at any time with `/handheld handheld` or `/handheld pc`, and return to auto with `/handheld auto`.