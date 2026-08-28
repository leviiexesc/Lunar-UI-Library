# Lunar UI

**Simple. Powerful. Beautiful.**

Lunar UI is an original Luau interface library for Roblox. It is built around a violet, moonlit visual system and a compact chaining API for tools, experiences, and developer menus.

## Install

Place `LunarUI.lua` in your project as a ModuleScript, then require it from a client LocalScript:

```lua
local LunarUI = require(path.to.LunarUI)
```

For a published one-file build, host the built `main.lua` file at a URL you control:

```lua
local LunarUI = loadstring(game:HttpGet("https://your-domain.example/LunarUI.lua"))()
```

## Quick start

```lua
local Window = LunarUI:CreateWindow({
    Title = "Lunar UI",
    Subtitle = "Roblox UI Library",
    Theme = "Dark",
})

local Main = Window:AddTab({ Title = "Main", Icon = "☾" })
local Features = Main:AddSection({ Title = "Features" })

Features:AddToggle({
    Title = "Enable Feature",
    Default = false,
    Callback = function(value)
        print("Enabled:", value)
    end,
})
```

## Included controls

- Windows, tabs, sections, theme presets, notifications, and JSON config state
- Buttons, toggles, checkboxes, sliders, dropdowns, multi-select dropdowns, and textboxes
- Keybinds, color controls, labels, paragraphs, separators, images, progress bars, and search

See [Example.luau](Example.luau) for a complete client-side starting point.

## Addons

Addons/SaveManager.lua saves registered option values as JSON. Supply a storage
adapter in ordinary Roblox projects, or it will use readfile / writefile when
those APIs are provided by the target environment. Addons/InterfaceManager.lua
builds a Settings tab with theme and interface-toggle controls.

## Project layout

```text
Lunar UI/
├── LunarUI.lua          # standalone distributable module
├── Example.luau         # client-side usage example
├── default.project.json # Rojo project mapping
└── README.md
```

Lunar UI is independently designed and implemented; it is not affiliated with Fluent.
