<img align="right" width="180" height="180" src="https://raw.githubusercontent.com/caglayanadiguzel/handheldfriend/main/icon.png">

[![GitHub Last Commit](https://img.shields.io/github/last-commit/caglayanadiguzel/handheldfriend?logo=github&label=Updated)](https://github.com/caglayanadiguzel/handheldfriend/commits/main)
[![GitHub Issues](https://img.shields.io/github/issues/caglayanadiguzel/handheldfriend?logo=github&label=Issues)](https://github.com/caglayanadiguzel/handheldfriend/issues)
[![GitHub Commit Activity](https://img.shields.io/github/commit-activity/m/caglayanadiguzel/handheldfriend?logo=github&label=Activity)](https://github.com/caglayanadiguzel/handheldfriend/commits/main)
<br>
[![WoW Retail](https://img.shields.io/badge/WoW-The%20War%20Within-blue?logo=battledotnet&logoColor=white)](https://worldofwarcraft.blizzard.com)
[![Lua](https://img.shields.io/badge/Lua-%232C2D72.svg?&logo=lua&logoColor=white)](https://lua.org)
[![Visual Studio Code](https://img.shields.io/badge/Visual%20Studio%20Code-0078d7.svg?&logo=visual-studio-code&logoColor=white)](https://code.visualstudio.com)
[![GitHub](https://img.shields.io/badge/GitHub-%23121011.svg?&logo=github&logoColor=white)](https://github.com/caglayanadiguzel/handheldfriend)

<br>

# Handheld Friend

A World of Warcraft retail addon that automatically switches your Edit Mode UI layout and toggles Action Bars when you move between a handheld device (ROG Ally) and a desktop PC.

## Features

- **Auto device detection** — uses the connected gamepad as the signal: gamepad present = handheld, no gamepad = PC.
- **Edit Mode layout switching** — applies your configured layout automatically on login or UI reload.
- **Action Bars 2–8 toggle** — hides them in handheld mode for a cleaner screen, restores them in PC mode.
- **Combat-safe** — defers any pending switch until combat ends.
- **ElvUI-compatible** — applies settings after ElvUI finishes its own layout restore on login.
- **Auto-enables Controller Support** — turns on WoW's built-in gamepad support on login so detection works out of the box.
- **Manual override** — force handheld or PC mode anytime via slash commands.

## Installation

**Developers (recommended):** Run the included link script to create a live link from your WoW AddOns folder to this repo — edits are reflected in-game instantly without copying files.

- **Windows:** Run `Link HandheldFriend to WoW.bat` — auto-detects your WoW install and creates a junction in `_retail_\Interface\AddOns\`.
- **macOS:** Run `Link HandheldFriend to WoW.sh` — links the addon into `_retail_/Interface/AddOns/` using hard links.

**Manual install:** Copy or clone this repo into:
```
<WoW Install>\_retail_\Interface\AddOns\HandheldFriend\
```

Then log in to WoW and open **Options → AddOns → Handheld Friend** to assign your layouts.

## Configuration

Open the in-game settings panel at **Options → AddOns → Handheld Friend**:

| Setting | Description |
|---|---|
| Handheld Layout | Edit Mode preset to activate when a gamepad is connected |
| PC Layout | Edit Mode preset to activate when no gamepad is connected |

Layouts are populated from your saved Edit Mode presets — create them in Edit Mode first, then select them here.

## Slash Commands

| Command | Effect |
|---|---|
| `/handheld` | Show help |
| `/handheld auto` | Auto-detect via gamepad (default) |
| `/handheld handheld` | Force handheld mode |
| `/handheld pc` | Force PC mode |
| `/handheld apply` | Re-apply current settings immediately |
| `/handheld debug` | Print detected device, layout, and mode info |

## Requirements

- **WoW Retail** — The War Within (patch 11.0.7+)
- Two saved Edit Mode presets (one for handheld, one for PC)
- ROG Ally or any gamepad-equipped device for auto-detection

## How Detection Works

In **auto** mode the addon calls `C_GamePad.GetAllDeviceIDs()` on login. If any gamepad is connected, it activates the handheld layout and hides Action Bars 2–8. If no gamepad is found, it activates the PC layout and shows all Action Bars.

You can override detection at any time with `/handheld handheld` or `/handheld pc`, and return to auto with `/handheld auto`.

## Problem? Suggestion?

- [Open an Issue](https://github.com/caglayanadiguzel/handheldfriend/issues)
