local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LunarUI = require(ReplicatedStorage:WaitForChild("LunarUI"))
local Addons = ReplicatedStorage:WaitForChild("LunarUIAddons")
local SaveManager = require(Addons:WaitForChild("SaveManager"))
local InterfaceManager = require(Addons:WaitForChild("InterfaceManager"))

local Window = LunarUI:CreateWindow({
    Title = "Lunar UI",
    Subtitle = "Roblox UI Library",
    Theme = "Dark",
})

local Main = Window:AddTab({ Title = "Main", Icon = "☾" })
local Settings = Window:AddTab({ Title = "Settings", Icon = "⚙" })
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
