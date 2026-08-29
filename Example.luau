-- Roblox Studio / Rojo example
local Lunar = loadstring(game:HttpGet("https://raw.githubusercontent.com/leviiexesc/Lunar-UI-Library/refs/heads/main/LunarUI.lua"))()

-- Optional: register your uploaded Lucide decals.
-- Lunar:RegisterLucideIcons({ home = "rbxassetid://123", settings = "rbxassetid://456" })

local Window = Lunar:CreateWindow({
    Title = "Lunar UI",
    Subtitle = "Roblox UI Library",
    Theme = "LiquidGlass",
    LauncherIcon = "home",
})

local Main = Window:AddTab({ Title = "Main", Icon = "home" })
local Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
Window:AddTab({ Title = "More", Icon = "circle" })

local Section = Main:AddSection({ Title = "Section" })

Section:AddButton({
    Title = "Button",
    ButtonText = "Click Me",
    Callback = function()
        print("Button clicked!")
    end,
})

Section:AddToggle({
    Title = "Toggle Switch",
    Default = true,
    Callback = function(value)
        print("Toggle:", value)
    end,
})

Section:AddSlider({
    Title = "Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("Slider:", value)
    end,
})

Section:AddDropdown({
    Title = "Dropdown",
    Values = { "Option 1", "Option 2", "Option 3" },
    Default = "Select...",
})

Section:AddMultiDropdown({
    Title = "Multi Dropdown",
    Values = { "Option 1", "Option 2", "Option 3" },
})

local Paragraph = Main:AddSection({ Title = "Paragraph" })
Paragraph:AddParagraph({
    Title = "Paragraph",
    Content = "Discription",
})

local Appearance = Settings:AddSection({ Title = "Appearance" })
Appearance:AddDropdown({
    Title = "Theme",
    Values = { "LiquidGlass", "Dark", "Light", "Halloween", "Christmas", "Summer" },
    Default = "LiquidGlass",
    Callback = function(value)
        Window:SetTheme(value)
    end,
})
