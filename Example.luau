local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LunarUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/leviiexesc/Lunar-UI-Library/refs/heads/main/LunarUI.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/leviiexesc/Lunar-UI-Library/refs/heads/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/leviiexesc/Lunar-UI-Library/refs/heads/main/Addons/InterfaceManager.lua"))()

-- Register your Roblox-uploaded Lucide assets once. The keys are exact names
-- from https://lucide.dev/icons/ and can be used in Icon = "..." below.
--[[
LunarUI:SetLucideIconProvider({
    home = "rbxassetid://YOUR_HOME_LUCIDE_ASSET_ID",
    settings = "rbxassetid://YOUR_SETTINGS_LUCIDE_ASSET_ID",
})
]]

local Window = LunarUI:CreateWindow({
    Title = "Lunar UI",
    Subtitle = "Roblox UI Library",
    Theme = "Dark",
    LauncherIcon = "home",
    CustomCursor = true,
})

local Main = Window:AddTab({ Title = "Main", Icon = "home" })
local Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
local Features = Main:AddSection({ Title = "Features" })

Features:AddButton({
    Title = "Click Me",
    ButtonText = "Run",
    Callback = function() print("Button clicked!") end,
})

local EnableFeature = Features:AddToggle("EnableFeature", {
    Title = "Enable Feature",
    Default = false,
    Callback = function(value) print("Enabled:", value) end,
})
EnableFeature:OnChanged(function(value)
    print("Option object changed:", value)
end)

local WalkSpeed = Features:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Min = 0, Max = 100, Default = 16,
    Callback = function(value) print(value) end,
})
WalkSpeed:SetValue(20)

Features:AddDropdown({
    Title = "Server Region",
    Values = { "Singapore", "Frankfurt", "Virginia" },
    Callback = function(value) print("Region:", value) end,
})

Features:AddDropdown("EnabledModules", {
    Title = "Enabled Modules",
    Description = "Choose more than one module.",
    Values = { "Lighting", "Particles", "Analytics" },
    Multi = true,
    Default = { "Lighting" },
})

Features:AddParagraph({
    Title = "Lunar UI",
    Content = "Simple. Powerful. Beautiful.",
})

Window:Notify({ Title = "Ready for launch", Content = "Your Lunar UI window has been created." })

SaveManager:SetLibrary(LunarUI)
SaveManager:SetFolder("LunarUIConfigs")
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(Settings)

InterfaceManager:SetLibrary(LunarUI)
InterfaceManager:SetWindow(Window)
InterfaceManager:BuildInterfaceSection(Settings)

-- The small crescent launcher appears when the user closes the window.
-- Tap/click it to reopen Lunar UI; this is mobile-friendly by default.
