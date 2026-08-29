local Lunar = loadstring(game:HttpGet("https://raw.githubusercontent.com/leviiexesc/Lunar-UI-Library/refs/heads/main/LunarUI.lua"))()

local Window = Lunar:CreateWindow({
    Title = "Lunar UI",
    Theme = "LiquidGlass",
    CustomCursor = true,
    LauncherIcon = "home",
})

local Main = Window:AddTab({ Title = "Main" })
local Settings = Window:AddTab({ Title = "Settings" })
local More = Window:AddTab({ Title = "More" })

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
    Callback = function(Value)
        print(Value)
    end,
})

Section:AddSlider({
    Title = "Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(Value)
        print(Value)
    end,
})

Section:AddDropdown({
    Title = "Dropdown",
    Values = { "Option 1", "Option 2", "Option 3" },
    Default = "Select...",
    Callback = function(Value)
        print(Value)
    end,
})

Section:AddDropdown("MultiDropdown", {
    Title = "Multi Dropdown",
    Values = { "Option 1", "Option 2", "Option 3" },
    Multi = true,
    Default = { "Option 1" },
})

local Paragraph = Main:AddSection({ Title = "Paragraph" })
Paragraph:AddParagraph({
    Title = "Paragraph",
    Content = "Discription",
})

local smallLauncher = Instance.new("Frame")
smallLauncher.Name = "LunarCompactLauncher"
smallLauncher.Size = UDim2.fromOffset(26, 26)
smallLauncher.Position = UDim2.new(0, 18, 1, -44)
smallLauncher.AnchorPoint = Vector2.new(0, 1)
smallLauncher.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
smallLauncher.BackgroundTransparency = 0.12
smallLauncher.BorderSizePixel = 0
smallLauncher.Parent = Window.Gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = smallLauncher

local glow = Instance.new("UIStroke")
glow.Color = Color3.fromRGB(208, 203, 255)
glow.Transparency = 0.5
glow.Thickness = 1
glow.Parent = smallLauncher

local moon = Instance.new("TextLabel")
moon.BackgroundTransparency = 1
moon.Size = UDim2.fromScale(1, 1)
moon.Text = "☾"
moon.Font = Enum.Font.GothamBold
moon.TextSize = 14
moon.TextColor3 = Color3.fromRGB(245, 245, 248)
moon.Parent = smallLauncher

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Position = UDim2.new(0, 38, 1, -20)
hint.Size = UDim2.new(0, 220, 0, 20)
hint.Text = "Small icon open close UI"
hint.Font = Enum.Font.Gotham
hint.TextSize = 8
hint.TextColor3 = Color3.fromRGB(184, 188, 200)
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Parent = Window.Gui

smallLauncher.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Window:Toggle()
    end
end)

Window:Notify({ Title = "Lunar UI", Content = "Liquid glass interface ready." })

-- Example theme and component API matching the reference window layout.
local MainSettings = Settings:AddSection({ Title = "Main" })
MainSettings:AddToggle({
    Title = "Smooth Motion",
    Default = true,
})
MainSettings:AddDropdown({
    Title = "Theme",
    Values = { "LiquidGlass", "Dark", "Light" },
    Default = "LiquidGlass",
})

More:AddSection({ Title = "More" })
More:AddParagraph({
    Title = "Paragraph",
    Content = "Discription",
})

local function openWindow()
    Window.Root.Visible = true
end

local function closeWindow()
    Window.Root.Visible = false
end

window = Window

