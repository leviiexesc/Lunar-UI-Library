--[[
    Lunar UI — Simple. Powerful. Beautiful.
    Standalone Roblox/Luau interface library.

    Example:
        local LunarUI = require(path.to.LunarUI)
        local Window = LunarUI:CreateWindow({ Title = "Lunar UI", Subtitle = "Roblox UI Library" })
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LunarUI = { Version = "1.0.0", AnimationsEnabled = true, AnimationStyle = "Fluid" }
LunarUI.__index = LunarUI
LunarUI.Icons = {}
LunarUI.IconProvider = nil
LunarUI.Lucide = {}

local Themes = {
    Dark = {
        Background = Color3.fromRGB(2, 6, 12), Surface = Color3.fromRGB(7, 13, 23),
        SurfaceHover = Color3.fromRGB(13, 25, 41), Border = Color3.fromRGB(27, 48, 73),
        Text = Color3.fromRGB(240, 248, 255), Muted = Color3.fromRGB(132, 157, 181),
        Accent = Color3.fromRGB(0, 153, 255), AccentSoft = Color3.fromRGB(0, 70, 140),
    },
    Light = {
        Background = Color3.fromRGB(238, 239, 247), Surface = Color3.fromRGB(255, 255, 255),
        SurfaceHover = Color3.fromRGB(241, 242, 249), Border = Color3.fromRGB(211, 214, 229),
        Text = Color3.fromRGB(30, 33, 48), Muted = Color3.fromRGB(102, 109, 132),
        Accent = Color3.fromRGB(0, 122, 214), AccentSoft = Color3.fromRGB(203, 231, 255),
    },
}

local function make(class, props, parent)
    local item = Instance.new(class)
    for key, value in pairs(props or {}) do item[key] = value end
    item.Parent = parent
    return item
end

local function corner(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

local function stroke(parent, color, transparency)
    return make("UIStroke", { Color = color, Transparency = transparency or 0, Thickness = 1 }, parent)
end

local function padding(parent, amount)
    return make("UIPadding", {
        PaddingTop = UDim.new(0, amount), PaddingBottom = UDim.new(0, amount),
        PaddingLeft = UDim.new(0, amount), PaddingRight = UDim.new(0, amount),
    }, parent)
end

local function tween(object, properties, duration)
    if not LunarUI.AnimationsEnabled then
        for property, value in pairs(properties) do object[property] = value end
        return
    end
    local geometric = properties.Position ~= nil or properties.Size ~= nil or properties.Rotation ~= nil or properties.Scale ~= nil
    local easing = Enum.EasingStyle.Quint
    if LunarUI.AnimationStyle == "Fluid" and geometric then
        easing = Enum.EasingStyle.Back
    elseif LunarUI.AnimationStyle == "Soft" then
        easing = Enum.EasingStyle.Sine
    end
    local speed = LunarUI.AnimationStyle == "Fast" and .65 or 1
    TweenService:Create(object, TweenInfo.new((duration or .18) * speed, easing, Enum.EasingDirection.Out), properties):Play()
end

local function getScale(object)
    local scale = object:FindFirstChild("LunarMotionScale")
    if not scale then scale = make("UIScale", { Name = "LunarMotionScale", Scale = 1 }, object) end
    return scale
end

local function pop(object, peak, duration)
    if not LunarUI.AnimationsEnabled or not object or not object.Parent then return end
    local scale = getScale(object)
    tween(scale, { Scale = peak or 1.045 }, (duration or .1) * .45)
    task.delay((duration or .1) * .45, function()
        if scale.Parent then tween(scale, { Scale = 1 }, duration or .16) end
    end)
end

local function appear(object, delay)
    local scale = getScale(object)
    scale.Scale = LunarUI.AnimationsEnabled and .96 or 1
    task.delay(delay or 0, function()
        if scale.Parent then tween(scale, { Scale = 1 }, .24) end
    end)
end

local function text(parent, value, size, color, props)
    props = props or {}
    props.BackgroundTransparency = 1
    props.Text = value or ""
    props.TextSize = size or 12
    props.TextColor3 = color
    props.Font = props.Font or Enum.Font.Gotham
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    props.Size = props.Size or UDim2.fromScale(1, 1)
    return make("TextLabel", props, parent)
end

local function button(parent, label, theme, props)
    props = props or {}
    props.Text = label
    props.Font = Enum.Font.GothamMedium
    props.TextSize = props.TextSize or 12
    props.TextColor3 = props.TextColor3 or theme.Text
    props.BackgroundColor3 = props.BackgroundColor3 or theme.SurfaceHover
    props.AutoButtonColor = false
    local item = make("TextButton", props, parent)
    corner(item, props.Radius or 7)
    local restingColor, restingTransparency = item.BackgroundColor3, item.BackgroundTransparency
    item.MouseEnter:Connect(function()
        if restingTransparency < 1 then tween(item, { BackgroundColor3 = restingColor:Lerp(theme.Accent, .15) }, .14) end
    end)
    item.MouseLeave:Connect(function()
        if restingTransparency < 1 then tween(item, { BackgroundColor3 = restingColor }, .18) end
    end)
    item.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tween(getScale(item), { Scale = .95 }, .08)
        end
    end)
    item.Activated:Connect(function()
        local scale = getScale(item)
        tween(scale, { Scale = 1.055 }, .1)
        task.delay(.1, function() if scale.Parent then tween(scale, { Scale = 1 }, .16) end end)
    end)
    return item
end

local function bindDrag(handle, target)
    local dragging, activeInput, dragStart, startPosition
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, activeInput, dragStart, startPosition = true, input, input.Position, target.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input == activeInput) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input == activeInput or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging, activeInput = false, nil
        end
    end)
end

local function bindLauncherDrag(launcher)
    local dragging, moved, inputStart, startPosition
    launcher.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, inputStart, startPosition = true, false, input.Position, launcher.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - inputStart
            if delta.Magnitude > 4 then moved = true end
            launcher.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            launcher:SetAttribute("Dragged", moved)
            task.delay(.08, function() if launcher.Parent then launcher:SetAttribute("Dragged", false) end end)
        end
    end)
end

-- Lucide-style icon registry. Register Roblox asset IDs under Lucide icon names.
-- Example: LunarUI:RegisterIcon("settings", "rbxassetid://123456789")
function LunarUI:RegisterIcon(name, assetId)
    assert(type(name) == "string", "Icon name must be a string.")
    assert(type(assetId) == "string" or type(assetId) == "number", "Icon asset ID must be a string or number.")
    self.Icons[string.lower(name)] = tostring(assetId):find("rbxassetid://") and tostring(assetId) or "rbxassetid://" .. tostring(assetId)
    return self
end

function LunarUI:SetIconProvider(provider)
    assert(type(provider) == "function" or provider == nil, "Icon provider must be a function or nil.")
    self.IconProvider = provider
    return self
end

-- Lucide-compatible name provider.
-- Map names from https://lucide.dev/icons/ to Roblox-uploaded image asset IDs.
-- Example: LunarUI:SetLucideIconProvider({ home = 123, settings = 456 })
function LunarUI:SetLucideIconProvider(icons)
    assert(type(icons) == "table" or type(icons) == "function" or icons == nil, "Lucide provider must be a table, function, or nil.")
    self.Lucide = icons or {}
    return self
end

function LunarUI:GetIcon(name)
    if not name then return nil end
    if type(name) == "number" or tostring(name):find("rbxassetid://") then return tostring(name):find("rbxassetid://") and tostring(name) or "rbxassetid://" .. tostring(name) end
    local key = string.lower(tostring(name))
    local lucide = type(self.Lucide) == "function" and self.Lucide(key) or self.Lucide[key]
    local asset = self.Icons[key] or lucide or (self.IconProvider and self.IconProvider(key))
    if asset and not tostring(asset):find("rbxassetid://") then return "rbxassetid://" .. tostring(asset) end
    return asset
end

function LunarUI:CreateIcon(parent, name, options)
    options = options or {}
    local icon = Instance.new("ImageLabel")
    icon.BackgroundTransparency = 1
    icon.Image = self:GetIcon(name) or ""
    icon.ImageColor3 = options.Color or Color3.new(1, 1, 1)
    icon.ImageTransparency = options.Transparency or 0
    icon.Size = options.Size or UDim2.fromOffset(16, 16)
    icon.Position = options.Position or UDim2.new()
    icon.ZIndex = options.ZIndex or 1
    icon.Parent = parent
    return icon
end

function LunarUI:CreateIconFallback(parent, name, color, position, size, zIndex)
    local holder = make("Frame", {
        Name = "LunarIcon_" .. tostring(name), BackgroundTransparency = 1,
        BorderSizePixel = 0, Position = position, Size = size, ZIndex = zIndex or 2,
    }, parent)
    local layer = (zIndex or 2) + 1
    local key = string.lower(tostring(name))
    local function line(positionValue, frameSize, rotation)
        return make("Frame", { BackgroundColor3 = color, BorderSizePixel = 0, Position = positionValue, Size = frameSize, Rotation = rotation or 0, ZIndex = layer }, holder)
    end
    if key == "home" then
        line(UDim2.fromScale(.28,.52), UDim2.fromScale(.44,.36))
        line(UDim2.fromScale(.18,.31), UDim2.fromScale(.45,.10), 42)
        line(UDim2.fromScale(.38,.31), UDim2.fromScale(.45,.10), -42)
    elseif key == "settings" then
        local ring = line(UDim2.fromScale(.2,.2), UDim2.fromScale(.6,.6)); corner(ring, 100)
        ring.BackgroundTransparency = .25
        local core = line(UDim2.fromScale(.4,.4), UDim2.fromScale(.2,.2)); corner(core, 100)
        for _, rotation in ipairs({0,45,90,135}) do line(UDim2.fromScale(.46,.08), UDim2.fromScale(.08,.84), rotation) end
    elseif key == "search" then
        local ring = line(UDim2.fromScale(.12,.12), UDim2.fromScale(.55,.55)); corner(ring, 100)
        ring.BackgroundTransparency = .25
        line(UDim2.fromScale(.58,.61), UDim2.fromScale(.37,.10), 45)
    else
        local outer = line(UDim2.fromScale(.16,.16), UDim2.fromScale(.68,.68)); corner(outer, 4)
        local inner = line(UDim2.fromScale(.38,.38), UDim2.fromScale(.24,.24)); corner(inner, 2)
    end
    return holder
end

function LunarUI:CreateWindow(options)
    options = options or {}
    local themeName = options.Theme == "Light" and "Light" or "Dark"
    local theme = Themes[themeName]
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local gui = make("ScreenGui", { Name = "LunarUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, playerGui)
    local scale = make("UIScale", { Scale = 0.92 }, gui)
    local root = make("Frame", {
        Name = "Window", Size = UDim2.fromOffset(options.Width or 760, options.Height or 500),
        Position = UDim2.fromScale(.5, .5), AnchorPoint = Vector2.new(.5, .5),
        BackgroundColor3 = theme.Background, BackgroundTransparency = .08, BorderSizePixel = 0,
    }, gui)
    corner(root, 13); stroke(root, theme.Border, .18)
    local rootGradient = make("UIGradient", {
        Name = "LunarGlassGradient",
        Rotation = 28,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Accent:Lerp(theme.Background, .7)),
            ColorSequenceKeypoint.new(.35, theme.Background),
            ColorSequenceKeypoint.new(1, theme.SurfaceHover),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, .35),
            NumberSequenceKeypoint.new(.4, .08),
            NumberSequenceKeypoint.new(1, .24),
        }),
    }, root)
    local launcher = make("TextButton", {
        Name = "LunarLauncher", Text = "", TextSize = 21, Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1, 1, 1), BackgroundColor3 = theme.Accent,
        AutoButtonColor = false, Visible = options.Launcher ~= false, AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -22, 1, -22), Size = UDim2.fromOffset(54, 54), ZIndex = 100,
    }, gui)
    corner(launcher, 27); stroke(launcher, Color3.new(1, 1, 1), .72)
    bindLauncherDrag(launcher)
    local launcherIcon = LunarUI:GetIcon(options.LauncherIcon or "home")
    if launcherIcon then
        LunarUI:CreateIcon(launcher, options.LauncherIcon or "home", {
            Color = Color3.new(1, 1, 1), Size = UDim2.fromOffset(24, 24),
            Position = UDim2.fromOffset(15, 15), ZIndex = 101,
        })
    else
        LunarUI:CreateIconFallback(launcher, options.LauncherIcon or "home", Color3.new(1,1,1), UDim2.fromOffset(15,15), UDim2.fromOffset(24,24), 101)
    end
    make("ImageLabel", { BackgroundTransparency = 1, Image = "rbxassetid://5028857084", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = .72, Size = UDim2.fromScale(1, 1), ZIndex = 0 }, root)
    local topbar = make("Frame", { BackgroundColor3 = theme.Surface, BackgroundTransparency = .12, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 56) }, root)
    corner(topbar, 13)
    make("Frame", { BackgroundColor3 = theme.Surface, BackgroundTransparency = .12, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -13), Size = UDim2.new(1, 0, 0, 13) }, topbar)
    text(topbar, options.Title or "Lunar UI", 15, theme.Text, { Position = UDim2.fromOffset(18, 9), Size = UDim2.new(1, -137, 0, 20), Font = Enum.Font.GothamBold })
    text(topbar, options.Subtitle or "Simple. Powerful. Beautiful.", 10, theme.Muted, { Position = UDim2.fromOffset(18, 28), Size = UDim2.new(1, -137, 0, 17) })
    local controls = make("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(108, 56), Position = UDim2.new(1, -116, 0, 0) }, topbar)
    local layout = make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6) }, controls)
    local function control(icon)
        return button(controls, icon, theme, { Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1, TextColor3 = theme.Muted, TextSize = 16 })
    end
    local minimize, maximize, close = control("-"), control("O"), control("x")
    local body = make("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 1, -56), ClipsDescendants = true }, root)
    local sidebar = make("Frame", { BackgroundColor3 = theme.Surface, BackgroundTransparency = .16, BorderSizePixel = 0, Size = UDim2.new(0, 165, 1, 0) }, body)
    local sideLayout = make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, sidebar); padding(sidebar, 10)
    local profile = make("Frame", { Name = "PlayerProfile", BackgroundColor3 = theme.Background, BackgroundTransparency = .28, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 48), LayoutOrder = -10 }, sidebar)
    corner(profile, 8); stroke(profile, theme.Border, .35)
    local avatar = make("ImageLabel", {
        Name = "Avatar", BackgroundColor3 = theme.AccentSoft, BorderSizePixel = 0,
        Position = UDim2.fromOffset(7, 7), Size = UDim2.fromOffset(34, 34),
        Image = "", ScaleType = Enum.ScaleType.Crop,
    }, profile)
    corner(avatar, 17)
    local localPlayer = Players.LocalPlayer
    local profileName = text(profile, localPlayer.DisplayName, 10, theme.Text, {
        Position = UDim2.fromOffset(49, 7), Size = UDim2.new(1, -56, 0, 16), Font = Enum.Font.GothamBold,
    })
    local profileUsername = text(profile, "@" .. localPlayer.Name, 8, theme.Muted, {
        Position = UDim2.fromOffset(49, 23), Size = UDim2.new(1, -56, 0, 15),
    })
    task.spawn(function()
        local ok, image = pcall(function()
            return Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and avatar.Parent then avatar.Image = image end
    end)
    local content = make("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 165, 0, 0), Size = UDim2.new(1, -165, 1, 0), ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Accent, CanvasSize = UDim2.new() }, body)
    padding(content, 18)
    local contentLayout = make("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, content)
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() content.CanvasSize = UDim2.fromOffset(0, contentLayout.AbsoluteContentSize.Y + 36) end)
    bindDrag(topbar, root)
    local window = setmetatable({ Gui = gui, Root = root, Launcher = launcher, Body = body, Sidebar = sidebar, Content = content, Profile = profile, Avatar = avatar, ProfileName = profileName, ProfileUsername = profileUsername, Theme = theme, ThemeName = themeName, Tabs = {}, Values = {}, Flags = {}, _activeTab = nil }, LunarUI)
    tween(scale, { Scale = 1 }, .35)
    minimize.MouseButton1Click:Connect(function()
        body.Visible = not body.Visible
        tween(root, { Size = UDim2.fromOffset(root.Size.X.Offset, body.Visible and (options.Height or 500) or 56) }, .24)
    end)
    maximize.MouseButton1Click:Connect(function()
        local maximized = root:GetAttribute("Maximized")
        root:SetAttribute("Maximized", not maximized)
        tween(root, { Size = maximized and UDim2.fromOffset(options.Width or 760, options.Height or 500) or UDim2.new(.92, 0, .88, 0), Position = UDim2.fromScale(.5, .5) }, .28)
    end)
    local function hideWindow()
        tween(scale, { Scale = .92 }, .2)
        task.delay(LunarUI.AnimationsEnabled and .2 or 0, function()
            if not root.Parent then return end
            root.Visible = false
            tween(launcher, { BackgroundColor3 = window.Theme.Accent }, .15)
        end)
    end
    close.MouseButton1Click:Connect(hideWindow)
    launcher.MouseButton1Click:Connect(function()
        if launcher:GetAttribute("Dragged") then return end
        if root.Visible then
            hideWindow()
            return
        end
        root.Visible = true
        scale.Scale = .92
        tween(scale, { Scale = 1 }, .24)
    end)
    window.Close = hideWindow
    return window
end

function LunarUI:AddTab(options)
    options = options or {}
    local tab = setmetatable({ Window = self, Sections = {} }, { __index = LunarUI })
    local title = options.Title or "Tab"
    local iconAsset = LunarUI:GetIcon(options.Icon)
    local nav = button(self.Sidebar, title, self.Theme, { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, TextColor3 = self.Theme.Muted, LayoutOrder = #self.Tabs + 1, TextXAlignment = Enum.TextXAlignment.Left })
    padding(nav, 10)
    if iconAsset then
        nav.TextXAlignment = Enum.TextXAlignment.Left
        nav.Text = "      " .. title
        LunarUI:CreateIcon(nav, options.Icon, { Color = self.Theme.Muted, Size = UDim2.fromOffset(15, 15), Position = UDim2.fromOffset(12, 9), ZIndex = 2 })
    elseif options.Icon then
        nav.Text = "      " .. title
        LunarUI:CreateIconFallback(nav, options.Icon, self.Theme.Accent, UDim2.fromOffset(12, 10), UDim2.fromOffset(13, 13), 2)
    end
    local page = make("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 1), Visible = false, AutomaticSize = Enum.AutomaticSize.Y }, self.Content)
    local layout = make("UIListLayout", { Padding = UDim.new(0, 11), SortOrder = Enum.SortOrder.LayoutOrder }, page)
    local function select()
        for _, item in pairs(self.Tabs) do item.Page.Visible = false; tween(item.Nav, { BackgroundTransparency = 1, TextColor3 = self.Theme.Muted }, .15) end
        page.Visible = true
        tween(nav, { BackgroundColor3 = self.Theme.AccentSoft, BackgroundTransparency = 0, TextColor3 = self.Theme.Text }, .15)
        pop(nav, 1.045, .16)
        appear(page)
        for index, child in ipairs(page:GetChildren()) do
            if child:IsA("GuiObject") then appear(child, index * .025) end
        end
        self._activeTab = tab
    end
    nav.MouseButton1Click:Connect(select)
    tab.Nav, tab.Page, tab.Layout, tab.Select = nav, page, layout, select
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then select() end
    return tab
end

function LunarUI:AddSection(options)
    options = options or {}
    local section = setmetatable({ Tab = self, Window = self.Window }, { __index = LunarUI })
    local frame = make("Frame", { BackgroundColor3 = self.Window.Theme.Surface, BackgroundTransparency = .18, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), AutomaticSize = Enum.AutomaticSize.Y }, self.Page)
    corner(frame, 9); stroke(frame, self.Window.Theme.Border, .3); padding(frame, 13)
    local layout = make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, frame)
    text(frame, options.Title or "Section", 11, self.Window.Theme.Text, { Size = UDim2.new(1, 0, 0, 18), Font = Enum.Font.GothamBold })
    appear(frame, (#self.Sections or 0) * .03)
    section.Frame, section.Layout = frame, layout
    table.insert(self.Sections, section)
    return section
end

function LunarUI:_row(title, description)
    local frame = make("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, description and 44 or 32) }, self.Frame)
    text(frame, title or "", 11, self.Window.Theme.Text, { Position = UDim2.fromOffset(0, 1), Size = UDim2.new(1, -155, 0, 18), Font = Enum.Font.GothamMedium })
    if description then text(frame, description, 9, self.Window.Theme.Muted, { Position = UDim2.fromOffset(0, 19), Size = UDim2.new(1, -155, 0, 16) }) end
    return frame
end

function LunarUI:AddButton(options)
    options = options or {}
    local row = self:_row(options.Title or "Button", options.Description)
    local action = button(row, options.ButtonText or "Execute", self.Window.Theme, { Position = UDim2.new(1, -112, .5, -14), Size = UDim2.fromOffset(112, 28), BackgroundColor3 = self.Window.Theme.Accent, TextColor3 = Color3.new(1,1,1) })
    action.MouseButton1Click:Connect(function() if options.Callback then options.Callback() end end)
    return action
end

function LunarUI:AddToggle(options)
    options = options or {}; local value = options.Default or false; local row = self:_row(options.Title or "Toggle", options.Description)
    local toggle = make("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = value and self.Window.Theme.Accent or self.Window.Theme.Border, Position = UDim2.new(1, -39, .5, -10), Size = UDim2.fromOffset(39, 20) }, row); corner(toggle, 12)
    local dot = make("Frame", { BackgroundColor3 = Color3.new(1,1,1), Size = UDim2.fromOffset(14,14), Position = UDim2.fromOffset(value and 22 or 3,3) }, toggle); corner(dot, 10)
    local function set(new) value = new; tween(toggle, { BackgroundColor3 = value and self.Window.Theme.Accent or self.Window.Theme.Border }, .16); tween(dot, { Position = UDim2.fromOffset(value and 22 or 3,3) }, .16); self.Window.Values[options.Flag or options.Title] = value; if options.Callback then options.Callback(value) end end
    toggle.MouseButton1Click:Connect(function() pop(toggle, 1.1, .15); set(not value) end); set(value); return { Set = set, Value = function() return value end }
end

function LunarUI:AddCheckbox(options) return self:AddToggle(options) end

function LunarUI:AddSlider(options)
    options = options or {}; local min, max = options.Min or 0, options.Max or 100; local value = math.clamp(options.Default or min, min, max); local row = self:_row(options.Title or "Slider", options.Description)
    local bar = make("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = self.Window.Theme.Border, Position = UDim2.new(1, -150, .5, -3), Size = UDim2.fromOffset(112, 6) }, row); corner(bar, 5)
    local fill = make("Frame", { BackgroundColor3 = self.Window.Theme.Accent, Size = UDim2.new((value-min)/(max-min),0,1,0) }, bar); corner(fill,5)
    local valueLabel = text(row, tostring(value), 10, self.Window.Theme.Muted, { Position = UDim2.new(1,-31,.5,-9), Size = UDim2.fromOffset(31,18), TextXAlignment = Enum.TextXAlignment.Right })
    local function set(number) value = math.clamp(math.floor(number + .5), min, max); fill.Size = UDim2.new((value-min)/(max-min),0,1,0); valueLabel.Text = tostring(value); self.Window.Values[options.Flag or options.Title] = value; if options.Callback then options.Callback(value) end end
    local dragging = false
    local function update(input) set(min + (max-min) * math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)) end
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; update(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end); set(value); return { Set=set, Value=function() return value end }
end

function LunarUI:AddTextbox(options)
    options = options or {}; local row = self:_row(options.Title or "Textbox", options.Description)
    local box = make("TextBox", { Text = options.Default or "", PlaceholderText = options.Placeholder or "Type here...", ClearTextOnFocus = false, TextColor3 = self.Window.Theme.Text, PlaceholderColor3 = self.Window.Theme.Muted, TextSize = 10, Font = Enum.Font.Gotham, BackgroundColor3 = self.Window.Theme.Background, Position = UDim2.new(1,-150,.5,-14), Size = UDim2.fromOffset(150,28) }, row); corner(box,6); stroke(box,self.Window.Theme.Border,.2); padding(box,8)
    box.FocusLost:Connect(function() self.Window.Values[options.Flag or options.Title] = box.Text; if options.Callback then options.Callback(box.Text) end end); return box
end

function LunarUI:AddDropdown(options)
    options = options or {}; local values, selected = options.Values or {}, options.Default; local row = self:_row(options.Title or "Dropdown", options.Description)
    local selector = button(row, selected or "Select...", self.Window.Theme, { Position = UDim2.new(1,-150,.5,-14), Size = UDim2.fromOffset(150,28), BackgroundColor3 = self.Window.Theme.Background, TextColor3 = self.Window.Theme.Muted })
    local arrow = text(selector, "v", 13, self.Window.Theme.Muted, { Position = UDim2.new(1,-25,0,0), Size = UDim2.fromOffset(20,28), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 3, Font = Enum.Font.GothamBold })
    local listHeight = #values*27+8
    local list = make("Frame", { Name="LunarDropdownOverlay", Visible=false, ClipsDescendants=true, BackgroundColor3=self.Window.Theme.SurfaceHover, BackgroundTransparency=.08, BorderSizePixel=0, Size=UDim2.fromOffset(150,0), ZIndex=50 }, self.Window.Gui); corner(list,7); stroke(list,self.Window.Theme.Border,.2); padding(list,4)
    local listLayout = make("UIListLayout",{Padding=UDim.new(0,2)},list)
    local opened = false
    local function setOpen(state)
        opened = state
        if state then
            list.Position=UDim2.fromOffset(selector.AbsolutePosition.X,selector.AbsolutePosition.Y+selector.AbsoluteSize.Y+4)
            list.Visible=true; list.Size=UDim2.fromOffset(150,0)
            tween(list,{Size=UDim2.fromOffset(150,listHeight)},.2); tween(arrow,{Rotation=180},.2)
        else
            tween(list,{Size=UDim2.fromOffset(150,0)},.16); tween(arrow,{Rotation=0},.16)
            task.delay(LunarUI.AnimationsEnabled and .16 or 0,function()if not opened and list.Parent then list.Visible=false end end)
        end
    end
    local function choose(value) selected=value; selector.Text=value; setOpen(false); self.Window.Values[options.Flag or options.Title]=value; if options.Callback then options.Callback(value) end end
    for _, value in ipairs(values) do local choice=button(list,tostring(value),self.Window.Theme,{Size=UDim2.new(1,0,0,25),BackgroundTransparency=1,TextColor3=self.Window.Theme.Text,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=51}); choice.MouseButton1Click:Connect(function() choose(value) end) end
    selector.MouseButton1Click:Connect(function() setOpen(not opened) end); return { Set=choose, Value=function() return selected end }
end

function LunarUI:AddMultiDropdown(options)
    options = options or {}; options.Default = options.Default or {}; local selected = {}
    for _, item in ipairs(options.Default) do selected[item] = true end
    local display = function() local parts={}; for item,on in pairs(selected) do if on then table.insert(parts,tostring(item)) end end; return #parts>0 and table.concat(parts,", ") or "Select..." end
    local control = self:AddDropdown({ Title=options.Title or "Multi-select", Description=options.Description, Values=options.Values, Default=display(), Flag=options.Flag, Callback=function(value) selected[value]=not selected[value]; if options.Callback then options.Callback(selected) end end })
    return control
end

function LunarUI:AddLabel(options) options=options or {}; return text(self.Frame, options.Text or options.Title or "Label", 10, self.Window.Theme.Muted, { Size=UDim2.new(1,0,0,18) }) end
function LunarUI:AddParagraph(options) options=options or {}; local frame=make("Frame",{BackgroundColor3=self.Window.Theme.Background,BorderSizePixel=0,Size=UDim2.new(1,0,0,52)},self.Frame);corner(frame,6);padding(frame,9);text(frame,options.Title or "Paragraph",10,self.Window.Theme.Text,{Size=UDim2.new(1,0,0,16),Font=Enum.Font.GothamBold});text(frame,options.Content or "",9,self.Window.Theme.Muted,{Position=UDim2.fromOffset(0,17),Size=UDim2.new(1,0,0,26),TextWrapped=true});return frame end
function LunarUI:AddSeparator() return make("Frame",{BackgroundColor3=self.Window.Theme.Border,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)},self.Frame) end
function LunarUI:AddImage(options) options=options or {}; return make("ImageLabel",{BackgroundColor3=self.Window.Theme.Background,Image=options.Image or "",ScaleType=Enum.ScaleType.Crop,Size=UDim2.new(1,0,0,options.Height or 100)},self.Frame) end
function LunarUI:AddKeybind(options) options=options or {}; local value=options.Default or Enum.KeyCode.RightControl; local row=self:_row(options.Title or "Keybind",options.Description);local key=button(row,value.Name,self.Window.Theme,{Position=UDim2.new(1,-90,.5,-14),Size=UDim2.fromOffset(90,28)});key.MouseButton1Click:Connect(function()key.Text="Press a key...";local c;c=UserInputService.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Keyboard then value=i.KeyCode;key.Text=value.Name;c:Disconnect();if options.Callback then options.Callback(value) end end end)end);return key end
function LunarUI:AddColorPicker(options) options=options or {}; local value=options.Default or self.Window.Theme.Accent; local row=self:_row(options.Title or "Color",options.Description);local swatch=button(row,"",self.Window.Theme,{Position=UDim2.new(1,-32,.5,-13),Size=UDim2.fromOffset(32,26),BackgroundColor3=value});swatch.MouseButton1Click:Connect(function()value=Color3.fromHSV((os.clock()%8)/8,.65,1);swatch.BackgroundColor3=value;if options.Callback then options.Callback(value) end end);return {Set=function(v)value=v;swatch.BackgroundColor3=v end,Value=function()return value end} end
function LunarUI:AddProgress(options)
    options=options or {}; local value=math.clamp(options.Value or 0,0,1); local row=self:_row(options.Title or "Progress",options.Description)
    local bar=make("Frame",{BackgroundColor3=self.Window.Theme.Border,BorderSizePixel=0,Position=UDim2.new(1,-150,.5,-3),Size=UDim2.fromOffset(150,6)},row);corner(bar,4)
    local fill=make("Frame",{BackgroundColor3=self.Window.Theme.Accent,BorderSizePixel=0,Size=UDim2.new(value,0,1,0)},bar);corner(fill,4)
    return {Set=function(v)value=math.clamp(v,0,1);tween(fill,{Size=UDim2.new(value,0,1,0)},.2)end,Value=function()return value end}
end
function LunarUI:AddSearch(options)
    options=options or {}; local row=self:_row(options.Title or "Search",options.Description)
    local box=make("TextBox",{Text="",PlaceholderText=options.Placeholder or "Search...",ClearTextOnFocus=false,TextColor3=self.Window.Theme.Text,PlaceholderColor3=self.Window.Theme.Muted,TextSize=10,Font=Enum.Font.Gotham,BackgroundColor3=self.Window.Theme.Background,Position=UDim2.new(1,-150,.5,-14),Size=UDim2.fromOffset(150,28)},row);corner(box,6);stroke(box,self.Window.Theme.Border,.2);padding(box,8)
    box:GetPropertyChangedSignal("Text"):Connect(function() if options.Callback then options.Callback(box.Text) end end);return box
end

function LunarUI:Notify(options)
    options = options or {}; local toast = make("Frame",{BackgroundColor3=self.Theme.Surface,BorderSizePixel=0,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-18,1,65),Size=UDim2.fromOffset(275,65)},self.Gui);corner(toast,9);stroke(toast,self.Theme.Border,.15)
    text(toast,options.Icon or "✦",19,self.Theme.Accent,{Position=UDim2.fromOffset(13,0),Size=UDim2.fromOffset(26,65),TextXAlignment=Enum.TextXAlignment.Center})
    text(toast,options.Title or "Lunar UI",11,self.Theme.Text,{Position=UDim2.fromOffset(49,11),Size=UDim2.new(1,-60,0,17),Font=Enum.Font.GothamBold})
    text(toast,options.Content or "",9,self.Theme.Muted,{Position=UDim2.fromOffset(49,29),Size=UDim2.new(1,-60,0,24),TextWrapped=true})
    tween(toast,{Position=UDim2.new(1,-18,1,-18)},.3);task.delay(options.Duration or 4,function()if toast.Parent then tween(toast,{Position=UDim2.new(1,-18,1,65)},.25);task.wait(.25);toast:Destroy()end end)
end

function LunarUI:GetConfig() return HttpService:JSONEncode(self.Values) end
function LunarUI:LoadConfig(config) local data=type(config)=="string" and HttpService:JSONDecode(config) or config;for flag,value in pairs(data)do if LunarUI.Options[flag] then LunarUI.Options[flag]:SetValue(value) else self.Values[flag]=value end end;return data end
function LunarUI:SelectTab(tab)
    if type(tab) == "number" then tab = self.Tabs[tab] end
    if tab and tab.Select then tab:Select() end
    return tab
end
function LunarUI:SetTheme(name)
    local nextTheme = Themes[name]
    if not nextTheme then return false, "Unknown theme: " .. tostring(name) end
    local previous = self.Theme
    local properties = { "BackgroundColor3", "TextColor3", "ImageColor3", "ScrollBarImageColor3" }
    for _, object in ipairs(self.Gui:GetDescendants()) do
        for _, property in ipairs(properties) do
            local ok, current = pcall(function() return object[property] end)
            if ok then
                for role, oldColor in pairs(previous) do
                    if typeof(oldColor) == "Color3" and current == oldColor and typeof(nextTheme[role]) == "Color3" then
                        pcall(function() object[property] = nextTheme[role] end)
                    end
                end
            end
        end
    end
    local glassGradient = self.Root:FindFirstChild("LunarGlassGradient")
    if glassGradient and glassGradient:IsA("UIGradient") then
        glassGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, nextTheme.Accent:Lerp(nextTheme.Background, .7)),
            ColorSequenceKeypoint.new(.35, nextTheme.Background),
            ColorSequenceKeypoint.new(1, nextTheme.SurfaceHover),
        })
    end
    self.Theme, self.ThemeName = nextTheme, name
    self.Values["LunarTheme"] = name
    return true
end
function LunarUI:SetAnimationsEnabled(enabled)
    self.AnimationsEnabled = enabled ~= false
    return self.AnimationsEnabled
end
function LunarUI:SetProfileNameVisible(visible)
    visible = visible ~= false
    self.Values["LunarProfileNames"] = visible
    for _, label in ipairs({ self.ProfileName, self.ProfileUsername }) do
        if label then
            if visible then
                label.Visible = true
                label.TextTransparency = 1
                tween(label, { TextTransparency = 0 }, .16)
            else
                tween(label, { TextTransparency = 1 }, .13)
                task.delay(LunarUI.AnimationsEnabled and .13 or 0, function()
                    if label.Parent and not self.Values["LunarProfileNames"] then label.Visible = false end
                end)
            end
        end
    end
    return visible
end
function LunarUI:SetAnimationStyle(style)
    assert(style == "Fluid" or style == "Soft" or style == "Fast", "Animation style must be Fluid, Soft, or Fast.")
    self.AnimationStyle = style
    return style
end
function LunarUI:Toggle()
    self.Root.Visible = not self.Root.Visible
    return self.Root.Visible
end
function LunarUI:Dialog(options)
    options=options or {}
    local shade=make("Frame",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.45,BorderSizePixel=0,Size=UDim2.fromScale(1,1),ZIndex=30},self.Gui)
    local dialog=make("Frame",{BackgroundColor3=self.Theme.Surface,BorderSizePixel=0,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(330,150),ZIndex=31},shade);corner(dialog,10);stroke(dialog,self.Theme.Border,.15);padding(dialog,16)
    text(dialog,options.Title or "Lunar UI",13,self.Theme.Text,{Size=UDim2.new(1,0,0,22),Font=Enum.Font.GothamBold,ZIndex=32})
    text(dialog,options.Content or "",10,self.Theme.Muted,{Position=UDim2.fromOffset(16,43),Size=UDim2.new(1,-32,0,48),TextWrapped=true,ZIndex=32})
    local holder=make("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,16,1,-43),Size=UDim2.new(1,-32,0,28),ZIndex=32},dialog)
    local layout=make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,6)},holder)
    for _, choice in ipairs(options.Buttons or {{Title="Close"}}) do
        local action=button(holder,choice.Title or "Action",self.Theme,{Size=UDim2.fromOffset(78,28),BackgroundColor3=choice.Primary and self.Theme.Accent or self.Theme.SurfaceHover,TextColor3=choice.Primary and Color3.new(1,1,1) or self.Theme.Text,ZIndex=33})
        action.MouseButton1Click:Connect(function() if choice.Callback then choice.Callback() end shade:Destroy() end)
    end
    return dialog
end
function LunarUI:Destroy() self.Unloaded=true; self.Gui:Destroy() end

-- Fluent-like ergonomic option objects, implemented specifically for Lunar UI.
LunarUI.Options = LunarUI.Options or {}
local function optionObject(flag, initial, set)
    local option={Value=initial,_changed={}}
    function option:SetValue(value) set(value) end
    function option:OnChanged(callback) table.insert(self._changed,callback);return callback end
    function option:_emit(value) self.Value=value;for _,callback in ipairs(self._changed) do task.spawn(callback,value) end end
    LunarUI.Options[flag]=option
    return option
end
local function normalize(flag, options)
    if type(flag)=="table" then options=flag;flag=options.Flag or options.Title end
    options=options or {};flag=flag or options.Flag or options.Title or ("Option_"..tostring(os.clock()))
    options.Flag=flag
    return flag,options
end
local rawToggle,rawSlider,rawDropdown,rawTextbox,rawKeybind,rawColorpicker=LunarUI.AddToggle,LunarUI.AddSlider,LunarUI.AddDropdown,LunarUI.AddTextbox,LunarUI.AddKeybind,LunarUI.AddColorPicker
function LunarUI:AddToggle(flag,options)
    flag,options=normalize(flag,options);local user=options.Callback;local api
    options.Callback=function(value) if user then user(value) end;if api then api:_emit(value) end end
    local control=rawToggle(self,options);api=optionObject(flag,control:Value(),function(value)control.Set(value)end);return api
end
function LunarUI:AddCheckbox(flag,options) return self:AddToggle(flag,options) end
function LunarUI:AddSlider(flag,options)
    flag,options=normalize(flag,options);local user=options.Callback;local api
    options.Callback=function(value) if user then user(value) end;if api then api:_emit(value) end end
    local control=rawSlider(self,options);api=optionObject(flag,control:Value(),function(value)control.Set(value)end);return api
end
function LunarUI:AddDropdown(flag,options)
    flag,options=normalize(flag,options)
    if options.Multi then return self:AddMultiDropdown(flag,options) end
    if type(options.Default)=="number" then options.Default=(options.Values or {})[options.Default] end
    local user=options.Callback;local api
    options.Callback=function(value)if user then user(value)end;if api then api:_emit(value)end end
    local control=rawDropdown(self,options);api=optionObject(flag,control:Value(),function(value)control.Set(value)end);return api
end
function LunarUI:AddMultiDropdown(flag,options)
    flag,options=normalize(flag,options);local selected={}
    if type(options.Default)=="table" then for key,value in pairs(options.Default) do selected[type(key)=="number" and value or key]=type(key)=="number" and true or value end end
    local values=options.Values or {};local row=self:_row(options.Title or flag,options.Description)
    local selector=button(row,"Select...",self.Window.Theme,{Position=UDim2.new(1,-150,.5,-14),Size=UDim2.fromOffset(150,28),BackgroundColor3=self.Window.Theme.Background,TextColor3=self.Window.Theme.Muted})
    local arrow=text(selector,"v",13,self.Window.Theme.Muted,{Position=UDim2.new(1,-25,0,0),Size=UDim2.fromOffset(20,28),TextXAlignment=Enum.TextXAlignment.Center,ZIndex=3,Font=Enum.Font.GothamBold})
    local listHeight=math.min(#values,6)*27+8
    local list=make("Frame",{Name="LunarMultiDropdownOverlay",Visible=false,BackgroundColor3=self.Window.Theme.SurfaceHover,BackgroundTransparency=.08,BorderSizePixel=0,Size=UDim2.fromOffset(150,0),ZIndex=50,ClipsDescendants=true},self.Window.Gui);corner(list,7);stroke(list,self.Window.Theme.Border,.2);padding(list,4);make("UIListLayout",{Padding=UDim.new(0,2)},list)
    local api
    local function render() local parts={};for _,value in ipairs(values)do if selected[value]then table.insert(parts,tostring(value))end end;selector.Text=#parts>0 and table.concat(parts,", ")or"Select...";self.Window.Values[flag]=selected;if options.Callback then options.Callback(selected)end;if api then api:_emit(selected)end end
    for _,value in ipairs(values)do local item=button(list,(selected[value]and"✓  "or"   ")..tostring(value),self.Window.Theme,{Size=UDim2.new(1,0,0,25),BackgroundTransparency=1,TextColor3=self.Window.Theme.Text,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=51});item.MouseButton1Click:Connect(function()selected[value]=not selected[value];item.Text=(selected[value]and"✓  "or"   ")..tostring(value);render()end)end
    local opened=false
    selector.MouseButton1Click:Connect(function()
        opened=not opened
        if opened then
            list.Position=UDim2.fromOffset(selector.AbsolutePosition.X,selector.AbsolutePosition.Y+selector.AbsoluteSize.Y+4);list.Visible=true;list.Size=UDim2.fromOffset(150,0)
            tween(list,{Size=UDim2.fromOffset(150,listHeight)},.2);tween(arrow,{Rotation=180},.2)
        else
            tween(list,{Size=UDim2.fromOffset(150,0)},.16);tween(arrow,{Rotation=0},.16)
            task.delay(LunarUI.AnimationsEnabled and .16 or 0,function()if not opened and list.Parent then list.Visible=false end end)
        end
    end)
    api=optionObject(flag,selected,function(value)selected=value or {};render()end);render();return api
end
function LunarUI:AddInput(flag,options)
    flag,options=normalize(flag,options);local user=options.Callback;local api
    options.Callback=function(value)if options.Numeric then value=tonumber(value)or 0 end;if user then user(value)end;if api then api:_emit(value)end end
    local control=rawTextbox(self,options)
    if not options.Finished then control:GetPropertyChangedSignal("Text"):Connect(function() options.Callback(control.Text) end) end
    api=optionObject(flag,control.Text,function(value)control.Text=tostring(value);options.Callback(control.Text)end);return api
end
function LunarUI:AddTextbox(flag,options) return self:AddInput(flag,options) end
function LunarUI:AddColorpicker(flag,options)
    flag,options=normalize(flag,options);local user=options.Callback;local api
    options.Callback=function(value)if user then user(value)end;if api then api:_emit(value)end end
    local control=rawColorpicker(self,options);api=optionObject(flag,control:Value(),function(value)control.Set(value)end);return api
end
function LunarUI:AddColorPicker(flag,options) return self:AddColorpicker(flag,options) end
function LunarUI:AddKeybind(flag,options)
    flag,options=normalize(flag,options);local user=options.Callback;local api
    if type(options.Default)=="string" then options.Default=Enum.KeyCode[options.Default] or Enum.KeyCode.RightControl end
    options.Callback=function(value)if api then api:_emit(value)end end
    local control=rawKeybind(self,options);api=optionObject(flag,options.Default or Enum.KeyCode.RightControl,function(value)control.Text=typeof(value)=="EnumItem"and value.Name or tostring(value)end)
    local mode,state,clicks=options.Mode or "Toggle",false,{}
    local function enum(value)
        if typeof(value)=="EnumItem" then return value end
        return Enum.KeyCode[value] or (value=="MB1" and Enum.UserInputType.MouseButton1) or (value=="MB2" and Enum.UserInputType.MouseButton2)
    end
    local function match(input)
        local value=enum(api.Value)
        return value and (input.KeyCode==value or input.UserInputType==value)
    end
    function api:GetState() return mode=="Always" or state end
    function api:OnClick(callback)table.insert(clicks,callback);return callback end
    function api:SetValue(value,newMode)
        self.Value=value;mode=newMode or mode;control.Text=typeof(value)=="EnumItem"and value.Name or tostring(value)
        if options.ChangedCallback then options.ChangedCallback(enum(value)) end
        self:_emit(value)
    end
    UserInputService.InputBegan:Connect(function(input,processed)
        if processed or not match(input) then return end
        if mode=="Hold" then state=true elseif mode=="Toggle" then state=not state else state=true end
        if user then user(state) end
        for _,callback in ipairs(clicks)do task.spawn(callback,state)end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if mode=="Hold" and match(input) then state=false;if user then user(false)end end
    end)
    return api
end

return LunarUI
