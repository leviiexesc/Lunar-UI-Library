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

## Lucide-style icons

Lunar UI accepts Lucide icon names in AddTab. Lucide distributes SVG icons, while
Roblox ImageLabels require Roblox-hosted image assets. Upload the Lucide SVG/PNG
assets to Roblox once, then map the original Lucide names to their asset IDs:

```lua
LunarUI:SetLucideIconProvider({
    settings = "rbxassetid://123456789",
    home = "rbxassetid://987654321",
})

Window:AddTab({ Title = "Settings", Icon = "settings" })
```

Each Lunar UI window automatically shows the local Roblox player's avatar,
DisplayName, and @Username in its sidebar. The compact bottom-right launcher
uses the named `home` icon when it has been registered.

See [Example.luau](Example.luau) for a complete client-side starting point.

## Addons

Addons/SaveManager.lua saves registered option values as JSON. Supply a storage
adapter in ordinary Roblox projects, or it will use readfile / writefile when
those APIs are provided by the target environment. Addons/InterfaceManager.lua
builds a Settings tab with theme and interface-toggle controls.

The interface settings include a Smooth animations toggle. When disabled, Lunar UI
applies UI changes immediately. A small moon launcher is visible in the
bottom-right corner on both mobile and desktop; tap it to toggle the interface.
Set Launcher = false in CreateWindow if you do not want this shortcut.

Use `LunarUI:SetAnimationStyle("Fluid")` for the default spring-like mobile
motion, `"Soft"` for gentler easing, or `"Fast"` for quick utility menus.

Every Lunar button uses press and pop feedback, and selected tabs/sections animate
into view. In the Interface section, **Show profile name** hides or shows the
DisplayName and @Username while leaving the Roblox avatar visible.

## Cursor and seasonal themes

```lua
local Window = LunarUI:CreateWindow({
    Theme = "Halloween", -- Dark, Light, Halloween, Christmas, Summer
    CustomCursor = true,
    CursorIcon = "rbxassetid://123456789", -- optional
})

Window:SetCustomCursor(false) -- restores Roblox's default mouse cursor
```

Halloween adds animated orange/purple falling rain streaks; Christmas adds
animated falling snow. Both effects update automatically when you call
Window:SetTheme().

## Project layout

```text
Lunar UI/
├── LunarUI.lua          # standalone distributable module
├── Example.luau         # client-side usage example
├── default.project.json # Rojo project mapping
└── README.md
```

Lunar UI is independently designed and implemented; it is not affiliated with Fluent.
