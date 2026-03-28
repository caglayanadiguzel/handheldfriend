# HandheldFriend — Project Guidelines for Claude

## What This Project Is
A World of Warcraft retail addon written in Lua that automatically switches the
Edit Mode UI layout and toggles Action Bars when the player moves between a
ROG Ally handheld and a desktop PC.

---

## Ground Rules

- **Never assume.** If anything is unclear, ask the user before writing code.
- **Always guide.** Explain what you are doing and why, especially when WoW API
  behavior is non-obvious.
- **If you cannot find an API or behavior, say so.** The user can look things up
  in-game or search forums. Do not guess and silently bake assumptions into code.
- **Step by step.** Implement one feature at a time and confirm before moving on.
- **No over-engineering.** This addon should stay simple and focused. Do not add
  features that were not asked for.

---

## Target Platform

- **WoW Version:** Retail (The War Within, latest patch)
- **Language:** Lua (WoW addon API)
- **Devices:** ROG Ally (handheld, Windows PC) and desktop PC
- **TOC Interface number:** Must be verified in-game with
  `/run print(select(4, GetBuildInfo()))` — do not hardcode and forget.

---

## Addon File Structure

```
HandheldFriend/
├── HandheldFriend.toc         ← Metadata, load order, SavedVariables declaration
├── HandheldFriend.lua         ← Core logic (detection, layout, action bars, events)
└── HandheldFriend_UI.lua      ← In-game settings panel (Options → AddOns)
```

The addon folder lives at the repo root. The user copies or symlinks it to:
`<WoW Install>\_retail_\Interface\AddOns\HandheldFriend\`

---

## User's Layout Configuration

| Mode     | Edit Mode Preset    | Action Bars 2–8 |
|----------|---------------------|-----------------|
| Handheld | "Rog Ally"          | OFF             |
| PC       | "ASUS Mobil Ekran"  | ON              |

Layout names are stored in `HandheldFriendDB` (SavedVariables) and are
configurable from the in-game panel — do not hardcode them in logic.

---

## Core Architecture

### Detection (hybrid)
- **Auto mode:** `C_GamePad.GetAllDeviceIDs()` — connected gamepad = handheld.
- **Manual override:** `HandheldFriendDB.mode` = `"auto"` | `"handheld"` | `"pc"`.
- Requirement: Controller Support must be ON in WoW Game Settings on the ROG Ally.

### Layout Switching
- API: `C_EditMode.SetActiveLayout(index)` — confirmed NOT a protected function.
- Get index by name: iterate `C_EditMode.GetLayouts().layouts`.
- Cannot be called during combat (`InCombatLockdown()`). Defer with `pendingApply`.

### Action Bars
- API: `Settings.SetValue("PROXY_SHOW_ACTIONBAR_N", bool)` for N = 2..8.
- **Old `SetCVar()` approach does NOT work in TWW.** Do not use it.
- Keys: `PROXY_SHOW_ACTIONBAR_2` through `PROXY_SHOW_ACTIONBAR_8`.

### Events
- `ADDON_LOADED` → init SavedVariables.
- `PLAYER_ENTERING_WORLD` (isInitialLogin or isReloadingUi) → apply settings.
- `PLAYER_REGEN_ENABLED` → apply deferred settings after combat ends.

### SavedVariables (`HandheldFriendDB`)
| Key             | Type   | Default              |
|-----------------|--------|----------------------|
| `mode`          | string | `"auto"`             |
| `handheldLayout`| string | `"Rog Ally"`         |
| `pcLayout`      | string | `"ASUS Mobil Ekran"` |

---

## In-Game Settings Panel

- Registered via `Settings.RegisterCanvasLayoutCategory(panel, "HandheldFriend")`.
- Accessible at: **Options → AddOns → HandheldFriend**.
- Dropdowns use `UIDropDownMenuTemplate` — populated dynamically from
  `C_EditMode.GetLayouts()` so the user can pick any saved preset.
- Panel refreshes on `OnShow` — reads DB state at open time, not at load time.

---

## Slash Commands

| Command              | Effect                              |
|----------------------|-------------------------------------|
| `/handheld auto`     | Auto-detect via gamepad             |
| `/handheld handheld` | Force handheld mode                 |
| `/handheld pc`       | Force PC mode                       |
| `/handheld apply`    | Re-apply settings immediately       |
| `/handheld`          | Print help                          |

---

## Key API Research Findings (do not re-research unless patch notes suggest changes)

- `C_EditMode.SetActiveLayout` — `SecretArguments = "AllowedWhenUntainted"` does NOT
  block addon calls with a plain index. Confirmed working in multiple addons.
- `Settings.SetValue("PROXY_SHOW_ACTIONBAR_N", bool)` — the only working method for
  action bar toggling in Dragonflight / TWW. CVars were removed.
- `C_GamePad.GetAllDeviceIDs()` — returns table of connected device IDs. Empty = no gamepad.
- Existing addons doing similar layout switching: Auto Layout Switcher, LayoutSwitcher.

---

## What Is NOT Done Yet (future steps)

- Testing in-game (user needs to install and verify).
- Verifying correct TOC interface number.
- Confirming `Settings.SetValue` timing — if action bars don't apply on first login,
  may need to defer or hook a later event.
- Any additional features the user requests after testing.
