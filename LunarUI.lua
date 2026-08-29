-- Lunar UI 2.0 | Original Roblox Liquid Glass UI library
-- Place this ModuleScript in ReplicatedStorage and require it from a LocalScript.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Lunar = { Version = "2.0.0", Options = {}, Icons = {}, Animations = true }

local Themes = {
    LiquidGlass = {
        Background = Color3.fromRGB(12, 12, 15), Surface = Color3.fromRGB(30, 30, 35),
        SurfaceTransparency = .07, Border = Color3.fromRGB(195, 195, 207),
        Text = Color3.fromRGB(249, 249, 251), Muted = Color3.fromRGB(181, 181, 191),
        Accent = Color3.fromRGB(223, 210, 243), AccentText = Color3.fromRGB(30, 27, 35),
        Active = Color3.fromRGB(63, 59, 71),
    },
    Dark = {
        Background = Color3.fromRGB(9, 9, 11), Surface = Color3.fromRGB(24, 24, 28),
        SurfaceTransparency = .08, Border = Color3.fromRGB(119, 119, 129),
        Text = Color3.fromRGB(248,248,250), Muted = Color3.fromRGB(170,170,180),
        Accent = Color3.fromRGB(235,235,240), AccentText = Color3.fromRGB(15,15,18),
        Active = Color3.fromRGB(61,61,69),
    },
    Light = {
        Background = Color3.fromRGB(231,231,234), Surface = Color3.fromRGB(255,255,255),
        SurfaceTransparency = .12, Border = Color3.fromRGB(154,154,164),
        Text = Color3.fromRGB(31,31,36), Muted = Color3.fromRGB(101,101,112),
        Accent = Color3.fromRGB(55,49,63), AccentText = Color3.fromRGB(255,255,255),
        Active = Color3.fromRGB(218,214,224),
    },
    Halloween = {
        Background = Color3.fromRGB(16,11,18), Surface = Color3.fromRGB(38,27,42),
        SurfaceTransparency = .17, Border = Color3.fromRGB(190,164,186),
        Text = Color3.fromRGB(255,248,244), Muted = Color3.fromRGB(203,182,193),
        Accent = Color3.fromRGB(242,222,205), AccentText = Color3.fromRGB(43,28,40),
        Active = Color3.fromRGB(77,55,74),
    },
    Christmas = {
        Background = Color3.fromRGB(9,15,12), Surface = Color3.fromRGB(24,38,30),
        SurfaceTransparency = .17, Border = Color3.fromRGB(177,201,185),
        Text = Color3.fromRGB(247,253,249), Muted = Color3.fromRGB(178,200,185),
        Accent = Color3.fromRGB(238,246,240), AccentText = Color3.fromRGB(19,32,24),
        Active = Color3.fromRGB(52,75,59),
    },
    Summer = {
        Background = Color3.fromRGB(235,235,238), Surface = Color3.fromRGB(255,255,255),
        SurfaceTransparency = .12, Border = Color3.fromRGB(164,164,174),
        Text = Color3.fromRGB(31,31,36), Muted = Color3.fromRGB(104,104,114),
        Accent = Color3.fromRGB(48,44,55), AccentText = Color3.fromRGB(255,255,255),
        Active = Color3.fromRGB(220,217,225),
    },
}

local function new(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do object[key] = value end
    object.Parent = parent
    return object
end
local function corner(parent, radius) return new("UICorner", { CornerRadius = UDim.new(0, radius or 7) }, parent) end
local function stroke(parent, color, transparency) return new("UIStroke", { Color = color, Transparency = transparency or 0, Thickness = 1 }, parent) end
local function pad(parent, value)
    return new("UIPadding", { PaddingTop=UDim.new(0,value), PaddingBottom=UDim.new(0,value), PaddingLeft=UDim.new(0,value), PaddingRight=UDim.new(0,value) }, parent)
end
local function animate(object, properties, duration)
    if not Lunar.Animations then for key,value in pairs(properties) do object[key]=value end return end
    TweenService:Create(object, TweenInfo.new(duration or .16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties):Play()
end
local function text(parent, value, size, color, properties)
    properties = properties or {}
    properties.BackgroundTransparency = 1; properties.Text = value or ""; properties.TextSize = size or 11
    properties.TextColor3 = color; properties.Font = properties.Font or Enum.Font.Gotham
    properties.TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Left
    properties.Size = properties.Size or UDim2.fromScale(1,1)
    return new("TextLabel", properties, parent)
end
local function scalePop(button)
    local scale = button:FindFirstChild("PressScale") or new("UIScale", { Name="PressScale", Scale=1 }, button)
    TweenService:Create(scale, TweenInfo.new(.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Scale=.96}):Play()
    task.delay(.08,function() if scale.Parent then TweenService:Create(scale,TweenInfo.new(.14,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play() end end)
end

function Lunar:RegisterLucideIcon(name, decalId)
    local id = tostring(decalId)
    self.Icons[string.lower(name)] = id:find("rbxassetid://") and id or "rbxassetid://" .. id
    return self
end
function Lunar:RegisterLucideIcons(icons) for name,id in pairs(icons or {}) do self:RegisterLucideIcon(name,id) end return self end
Lunar.RegisterIcon = Lunar.RegisterLucideIcon

local function icon(parent, name, theme, position, size, zIndex)
    local id = Lunar.Icons[string.lower(name or "")]
    if not id then return nil end
    return new("ImageLabel", { BackgroundTransparency=1, Image=id, ImageColor3=theme.Muted, Position=position, Size=size, ZIndex=zIndex or 2 }, parent)
end

local function option(flag, initial, setter)
    local control = { Value=initial, Changed={} }
    function control:SetValue(value) setter(value) end
    function control:OnChanged(callback) table.insert(self.Changed,callback); return callback end
    function control:_set(value)
        self.Value=value
        for _,callback in ipairs(self.Changed) do task.spawn(callback,value) end
    end
    Lunar.Options[flag]=control
    return control
end
local function normalize(flag, data)
    if type(flag)=="table" then data=flag;flag=data.Flag or data.Title end
    data=data or {};flag=flag or data.Flag or data.Title or ("Option_"..tostring(os.clock()));return flag,data
end
local function draggable(handle, target)
    local dragging,start,origin
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true;start=input.Position;origin=target.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-start;target.Position=UDim2.new(origin.X.Scale,origin.X.Offset+delta.X,origin.Y.Scale,origin.Y.Offset+delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
end

function Lunar:CreateWindow(data)
    data=data or {};local themeName=Themes[data.Theme] and data.Theme or "LiquidGlass";local theme=Themes[themeName]
    local player=Players.LocalPlayer
    local playerGui=player:WaitForChild("PlayerGui")
    local previous=playerGui:FindFirstChild("LunarUI")
    if previous then previous:Destroy() end
    UserInputService.MouseIconEnabled=true
    local gui=new("ScreenGui",{Name="LunarUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},playerGui)
    local root=new("Frame",{Name="Window",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=data.Size or UDim2.fromOffset(data.Width or 800,data.Height or 505),BackgroundColor3=theme.Background,BackgroundTransparency=.04,BorderSizePixel=0},gui)
    corner(root,12);stroke(root,theme.Border,.22)
    new("UIGradient",{Rotation=35,Color=ColorSequence.new(theme.Accent,theme.Background),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.88),NumberSequenceKeypoint.new(1,.98)})},root)
    local bar=new("Frame",{BackgroundColor3=theme.Surface,BackgroundTransparency=.16,BorderSizePixel=0,Size=UDim2.new(1,0,0,43)},root);corner(bar,12)
    new("Frame",{BackgroundColor3=theme.Surface,BackgroundTransparency=.16,BorderSizePixel=0,Position=UDim2.new(0,0,1,-10),Size=UDim2.new(1,0,0,10)},bar)
    text(bar,data.Title or "Lunar UI",16,theme.Text,{Position=UDim2.fromOffset(0,10),Size=UDim2.new(1,0,0,20),Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center})
    local windowControls=new("Frame",{BackgroundTransparency=1,Position=UDim2.new(1,-82,0,0),Size=UDim2.fromOffset(68,43)},bar)
    new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,7)},windowControls)
    local function systemButton(caption)return new("TextButton",{Text=caption,Font=Enum.Font.GothamMedium,TextSize=14,TextColor3=theme.Muted,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Size=UDim2.fromOffset(20,24)},windowControls)end
    local minimize,maximize,close=systemButton("-"),systemButton("o"),systemButton("x")
    local body=new("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,43),Size=UDim2.new(1,0,1,-43),ClipsDescendants=true},root)
    local sidebar=new("Frame",{BackgroundColor3=theme.Surface,BackgroundTransparency=.11,BorderSizePixel=0,Size=UDim2.new(0,148,1,0)},body)
    stroke(sidebar,theme.Border,.72);pad(sidebar,10);new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},sidebar)
    local search=new("TextBox",{Text="",PlaceholderText="Search...",ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=10,TextColor3=theme.Text,PlaceholderColor3=theme.Muted,BackgroundColor3=theme.Surface,BackgroundTransparency=.12,BorderSizePixel=0,Size=UDim2.new(1,0,0,32),LayoutOrder=-20},sidebar);corner(search,6);stroke(search,theme.Border,.46);pad(search,8)
    text(search,"o",12,theme.Muted,{Position=UDim2.new(1,-22,0,0),Size=UDim2.fromOffset(17,32),TextXAlignment=Enum.TextXAlignment.Center})
    local content=new("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0,148,0,0),Size=UDim2.new(1,-148,1,0),ScrollBarThickness=3,ScrollBarImageColor3=theme.Muted,CanvasSize=UDim2.new()},body)
    pad(content,15);local list=new("UIListLayout",{Padding=UDim.new(0,14),SortOrder=Enum.SortOrder.LayoutOrder},content)
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()content.CanvasSize=UDim2.fromOffset(0,list.AbsoluteContentSize.Y+36)end)
    local launcher=new("TextButton",{Name="CompactLauncher",Text="L",AutoButtonColor=false,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=theme.Text,BackgroundColor3=theme.Surface,BackgroundTransparency=.1,BorderSizePixel=0,Position=UDim2.new(0,18,1,-44),AnchorPoint=Vector2.new(0,1),Size=UDim2.fromOffset(27,27),ZIndex=100},gui);corner(launcher,20);stroke(launcher,theme.Border,.35)
    text(gui,"Small icon open close UI",8,theme.Muted,{Position=UDim2.new(0,54,1,-50),Size=UDim2.fromOffset(170,17),ZIndex=100})
    local window=setmetatable({Gui=gui,Root=root,Body=body,Sidebar=sidebar,Content=content,Theme=theme,ThemeName=themeName,Launcher=launcher,Tabs={},Values={},Search=search}, {__index=Lunar})
    draggable(bar,root)
    minimize.MouseButton1Click:Connect(function()body.Visible=not body.Visible;root.Size=UDim2.new(root.Size.X.Scale,root.Size.X.Offset,0,body.Visible and (data.Height or 505) or 43)end)
    maximize.MouseButton1Click:Connect(function()local state=root:GetAttribute("max")root:SetAttribute("max",not state);root.Size=state and (data.Size or UDim2.fromOffset(data.Width or 800,data.Height or 505)) or UDim2.new(.92,0,.88,0);root.Position=UDim2.fromScale(.5,.5)end)
    close.MouseButton1Click:Connect(function()root.Visible=false end);launcher.MouseButton1Click:Connect(function()root.Visible=not root.Visible end)
    return window
end

function Lunar:AddTab(data)
    data=data or {};local tab=setmetatable({Window=self},{__index=Lunar});local title=data.Title or "Tab"
    local nav=new("TextButton",{Text=title,Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=self.Theme.Muted,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Size=UDim2.new(1,0,0,35),LayoutOrder=#self.Tabs+1},self.Sidebar);corner(nav,7);pad(nav,9)
    local page=new("Frame",{BackgroundTransparency=1,Visible=false,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,1)},self.Content);new("UIListLayout",{Padding=UDim.new(0,14),SortOrder=Enum.SortOrder.LayoutOrder},page)
    function tab:Select()for _,item in ipairs(self.Window.Tabs)do item.Page.Visible=false;item.Nav.BackgroundTransparency=1;item.Nav.TextColor3=self.Window.Theme.Muted end;page.Visible=true;nav.BackgroundColor3=self.Window.Theme.Active;nav.BackgroundTransparency=.12;nav.TextColor3=self.Window.Theme.Text end
    nav.MouseButton1Click:Connect(function()tab:Select()end);tab.Nav=nav;tab.Page=page;table.insert(self.Tabs,tab);if #self.Tabs==1 then tab:Select()end
    search = self.Search
    search:GetPropertyChangedSignal("Text"):Connect(function()local query=string.lower(search.Text);for _,item in ipairs(self.Tabs)do item.Nav.Visible=query=="" or string.find(string.lower(item.Nav.Text),query,1,true)~=nil end end)
    return tab
end

function Lunar:AddSection(data)
    data=data or {};local section=setmetatable({Window=self.Window},{__index=Lunar})
    local frame=new("Frame",{BackgroundColor3=self.Window.Theme.Surface,BackgroundTransparency=self.Window.Theme.SurfaceTransparency,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,1)},self.Page);corner(frame,9);stroke(frame,self.Window.Theme.Border,.48);pad(frame,15);new("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},frame)
    text(frame,data.Title or "Section",11,self.Window.Theme.Text,{Size=UDim2.new(1,0,0,18),Font=Enum.Font.GothamBold});section.Frame=frame;return section
end
function Lunar:_row(title,description)
    local row=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,description and 46 or 30)},self.Frame);text(row,title or "",11,self.Window.Theme.Text,{Size=UDim2.new(1,-170,0,17),Font=Enum.Font.GothamMedium});if description then text(row,description,9,self.Window.Theme.Muted,{Position=UDim2.fromOffset(0,18),Size=UDim2.new(1,-170,0,22),TextWrapped=true})end;return row
end
function Lunar:AddButton(data)
    data=data or {};local row=self:_row(data.Title or "Button",data.Description);local b=new("TextButton",{Text=data.ButtonText or "Click Me",AutoButtonColor=false,Font=Enum.Font.GothamMedium,TextSize=10,TextColor3=self.Window.Theme.Text,BackgroundColor3=self.Window.Theme.Active,BackgroundTransparency=.12,BorderSizePixel=0,Position=UDim2.new(1,-130,.5,-13),Size=UDim2.fromOffset(130,26)},row);corner(b,6);stroke(b,self.Window.Theme.Border,.55);b.MouseButton1Click:Connect(function()scalePop(b);if data.Callback then data.Callback()end end);return b
end
function Lunar:AddToggle(flag,data)
    flag,data=normalize(flag,data);local value=data.Default==true;local row=self:_row(data.Title or flag,data.Description);local b=new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=value and Color3.fromRGB(59,204,119) or self.Window.Theme.Active,BorderSizePixel=0,Position=UDim2.new(1,-39,.5,-10),Size=UDim2.fromOffset(39,20)},row);corner(b,12);local dot=new("Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Position=UDim2.fromOffset(value and 22 or 3,3),Size=UDim2.fromOffset(14,14)},b);corner(dot,10);local api
    local function set(nextValue)value=nextValue==true;b.BackgroundColor3=value and Color3.fromRGB(59,204,119)or self.Window.Theme.Active;dot.Position=UDim2.fromOffset(value and 22 or 3,3);self.Window.Values[flag]=value;if data.Callback then data.Callback(value)end;if api then api:_set(value)end end
    b.MouseButton1Click:Connect(function()set(not value)end);api=option(flag,value,set);set(value);return api
end
function Lunar:AddCheckbox(flag,data)return self:AddToggle(flag,data)end
function Lunar:AddSlider(flag,data)
    flag,data=normalize(flag,data);local min,max=data.Min or 0,data.Max or 100;local value=math.clamp(data.Default or min,min,max);local row=self:_row(data.Title or flag,data.Description);local bar=new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=self.Window.Theme.Border,BorderSizePixel=0,Position=UDim2.new(1,-145,.5,-3),Size=UDim2.fromOffset(107,6)},row);corner(bar,6);local fill=new("Frame",{BackgroundColor3=self.Window.Theme.Accent,BorderSizePixel=0,Size=UDim2.new((value-min)/(max-min),0,1,0)},bar);corner(fill,6);local number=text(row,tostring(value),9,self.Window.Theme.Muted,{Position=UDim2.new(1,-30,.5,-9),Size=UDim2.fromOffset(30,17),TextXAlignment=Enum.TextXAlignment.Right});local api;local moving=false
    local function set(n)value=math.clamp(math.floor(n+.5),min,max);fill.Size=UDim2.new((value-min)/(max-min),0,1,0);number.Text=tostring(value);self.Window.Values[flag]=value;if data.Callback then data.Callback(value)end;if api then api:_set(value)end end
    local function setPointer(input)set(min+(max-min)*math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1))end
    bar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then moving=true;setPointer(i)end end);UserInputService.InputChanged:Connect(function(i)if moving then setPointer(i)end end);UserInputService.InputEnded:Connect(function()moving=false end);api=option(flag,value,set);set(value);return api
end
local function dropdown(section,flag,data,multi)
    local values=data.Values or {};local selected=multi and {} or data.Default;if not multi and type(selected)=="number"then selected=values[selected]end;if multi then for _,value in ipairs(data.Default or {})do selected[value]=true end end
    local row=section:_row(data.Title or flag,data.Description);local title=multi and "Select..."or(selected or "Select...");local select=new("TextButton",{Text=title.."                 v",AutoButtonColor=false,Font=Enum.Font.Gotham,TextSize=10,TextColor3=section.Window.Theme.Muted,TextXAlignment=Enum.TextXAlignment.Left,BackgroundColor3=section.Window.Theme.Background,BorderSizePixel=0,Position=UDim2.new(1,-150,.5,-13),Size=UDim2.fromOffset(150,26)},row);corner(select,6);stroke(select,section.Window.Theme.Border,.55)
    local overlay=new("Frame",{Visible=false,BackgroundColor3=section.Window.Theme.Surface,BackgroundTransparency=.08,BorderSizePixel=0,Size=UDim2.fromOffset(150,#values*26+8),ZIndex=80},section.Window.Gui);corner(overlay,7);stroke(overlay,section.Window.Theme.Border,.2);pad(overlay,4);new("UIListLayout",{Padding=UDim.new(0,2)},overlay);local opened=false;local api
    local function display()
        if multi then local out={};for _,item in ipairs(values)do if selected[item]then table.insert(out,tostring(item))end end;select.Text=(#out>0 and table.concat(out,", ")or"Select...").."                 v"else select.Text=tostring(selected or "Select...").."                 v"end
    end
    local function update(value)
        if multi then selected[value]=not selected[value]else selected=value;opened=false;overlay.Visible=false end
        display()
        section.Window.Values[flag]=selected
        if data.Callback then data.Callback(selected)end
        if api then api:_set(selected)end
    end
    for _,item in ipairs(values)do local choice=new("TextButton",{Text=(multi and "[ ]  "or"")..tostring(item),AutoButtonColor=false,Font=Enum.Font.Gotham,TextSize=10,TextColor3=section.Window.Theme.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,24),ZIndex=81},overlay);choice.MouseButton1Click:Connect(function()update(item);if multi then choice.Text=(selected[item]and"[x]  "or"[ ]  ")..tostring(item)end end)end
    select.MouseButton1Click:Connect(function()opened=not opened;overlay.Position=UDim2.fromOffset(select.AbsolutePosition.X,select.AbsolutePosition.Y+select.AbsoluteSize.Y+4);overlay.Visible=opened end);api=option(flag,multi and selected or selected,function(v)if multi then selected=v or {}else selected=v end;display()end);display();return api
end
function Lunar:AddDropdown(flag,data)flag,data=normalize(flag,data);return dropdown(self,flag,data,false)end
function Lunar:AddMultiDropdown(flag,data)flag,data=normalize(flag,data);return dropdown(self,flag,data,true)end
function Lunar:AddInput(flag,data)
    flag,data=normalize(flag,data);local row=self:_row(data.Title or flag,data.Description);local box=new("TextBox",{Text=data.Default or "",PlaceholderText=data.Placeholder or "Type here...",ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=10,TextColor3=self.Window.Theme.Text,PlaceholderColor3=self.Window.Theme.Muted,BackgroundColor3=self.Window.Theme.Background,BorderSizePixel=0,Position=UDim2.new(1,-150,.5,-13),Size=UDim2.fromOffset(150,26)},row);corner(box,6);stroke(box,self.Window.Theme.Border,.55);local api
    local function set(value)box.Text=tostring(value or "");self.Window.Values[flag]=box.Text;if data.Callback then data.Callback(box.Text)end;if api then api:_set(box.Text)end end
    box.FocusLost:Connect(function()set(box.Text)end);api=option(flag,box.Text,set);return api
end
Lunar.AddTextbox=Lunar.AddInput
function Lunar:AddKeybind(flag,data)
    flag,data=normalize(flag,data);local key=data.Default or Enum.KeyCode.RightControl
    if type(key)=="string" then key=Enum.KeyCode[key] or Enum.KeyCode.RightControl end
    local row=self:_row(data.Title or flag,data.Description)
    local button=new("TextButton",{Text=key.Name,AutoButtonColor=false,Font=Enum.Font.Gotham,TextSize=10,TextColor3=self.Window.Theme.Text,BackgroundColor3=self.Window.Theme.Active,BorderSizePixel=0,Position=UDim2.new(1,-100,.5,-13),Size=UDim2.fromOffset(100,26)},row);corner(button,6)
    local api;local listening=false
    local function set(value)
        if type(value)=="string" then value=Enum.KeyCode[value] or key end
        key=value;button.Text=key.Name;self.Window.Values[flag]=key.Name;if data.ChangedCallback then data.ChangedCallback(key)end;if api then api:_set(key)end
    end
    button.MouseButton1Click:Connect(function()
        if listening then return end;listening=true;button.Text="Press key..."
        local connection;connection=UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Keyboard then set(input.KeyCode);listening=false;connection:Disconnect()end
        end)
    end)
    UserInputService.InputBegan:Connect(function(input,processed)if not processed and input.KeyCode==key and data.Callback then data.Callback(true)end end)
    api=option(flag,key,set);function api:GetState()return false end;return api
end
function Lunar:AddColorpicker(flag,data)
    flag,data=normalize(flag,data);local value=data.Default or self.Window.Theme.Accent;local row=self:_row(data.Title or flag,data.Description)
    local swatch=new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=value,BorderSizePixel=0,Position=UDim2.new(1,-30,.5,-13),Size=UDim2.fromOffset(30,26)},row);corner(swatch,6);local api
    local function set(nextValue)value=nextValue;swatch.BackgroundColor3=value;self.Window.Values[flag]=value;if data.Callback then data.Callback(value)end;if api then api:_set(value)end end
    swatch.MouseButton1Click:Connect(function()set(Color3.fromHSV((os.clock()%10)/10,.55,1))end);api=option(flag,value,set);return api
end
Lunar.AddColorPicker=Lunar.AddColorpicker
function Lunar:AddKeybind(flag,data)
    flag,data=normalize(flag,data);local key=data.Default or Enum.KeyCode.RightControl
    if type(key)=="string" then key=Enum.KeyCode[key] or Enum.KeyCode.RightControl end
    local row=self:_row(data.Title or flag,data.Description);local bind=new("TextButton",{Text=key.Name,AutoButtonColor=false,Font=Enum.Font.Gotham,TextSize=10,TextColor3=self.Window.Theme.Text,BackgroundColor3=self.Window.Theme.Active,BorderSizePixel=0,Position=UDim2.new(1,-100,.5,-13),Size=UDim2.fromOffset(100,26)},row);corner(bind,6)
    local api;local listening=false
    local function set(value)
        if type(value)=="string" then value=Enum.KeyCode[value] or key end
        key=value;bind.Text=key.Name;self.Window.Values[flag]=key.Name
        if data.ChangedCallback then data.ChangedCallback(key)end
        if api then api:_set(key)end
    end
    bind.MouseButton1Click:Connect(function()
        if listening then return end;listening=true;bind.Text="Press key..."
        local connection;connection=UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Keyboard then set(input.KeyCode);listening=false;connection:Disconnect()end
        end)
    end)
    UserInputService.InputBegan:Connect(function(input,processed)
        if not processed and input.KeyCode==key and data.Callback then data.Callback(true)end
    end)
    api=option(flag,key,set);function api:GetState()return false end;return api
end
function Lunar:AddColorpicker(flag,data)
    flag,data=normalize(flag,data);local color=data.Default or self.Window.Theme.Accent;local row=self:_row(data.Title or flag,data.Description)
    local swatch=new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=color,BorderSizePixel=0,Position=UDim2.new(1,-30,.5,-13),Size=UDim2.fromOffset(30,26)},row);corner(swatch,6)
    local api;local function set(value)color=value;swatch.BackgroundColor3=color;self.Window.Values[flag]=color;if data.Callback then data.Callback(color)end;if api then api:_set(color)end end
    swatch.MouseButton1Click:Connect(function()local hue=(os.clock()%10)/10;set(Color3.fromHSV(hue,.55,1))end);api=option(flag,color,set);return api
end
Lunar.AddColorPicker=Lunar.AddColorpicker
function Lunar:AddProgress(data)
    data=data or {};local value=math.clamp(data.Value or 0,0,1);local row=self:_row(data.Title or "Progress",data.Description);local bar=new("Frame",{BackgroundColor3=self.Window.Theme.Border,BorderSizePixel=0,Position=UDim2.new(1,-150,.5,-3),Size=UDim2.fromOffset(150,6)},row);corner(bar,6);local fill=new("Frame",{BackgroundColor3=self.Window.Theme.Accent,BorderSizePixel=0,Size=UDim2.new(value,0,1,0)},bar);corner(fill,6);return{Set=function(_,nextValue)value=math.clamp(nextValue,0,1);fill.Size=UDim2.new(value,0,1,0)end,Value=function()return value end}
end
function Lunar:AddParagraph(data)data=data or {};local card=new("Frame",{BackgroundColor3=self.Window.Theme.Surface,BackgroundTransparency=self.Window.Theme.SurfaceTransparency,BorderSizePixel=0,Size=UDim2.new(1,0,0,63)},self.Frame);corner(card,7);stroke(card,self.Window.Theme.Border,.55);text(card,data.Title or "Paragraph",10,self.Window.Theme.Text,{Position=UDim2.fromOffset(10,10),Size=UDim2.new(1,-20,0,16),Font=Enum.Font.GothamBold});text(card,data.Content or "",9,self.Window.Theme.Muted,{Position=UDim2.fromOffset(10,29),Size=UDim2.new(1,-20,0,22),TextWrapped=true});return card end
function Lunar:AddLabel(data)data=data or {};return text(self.Frame,data.Text or data.Title or "Label",10,self.Window.Theme.Muted,{Size=UDim2.new(1,0,0,18)})end
function Lunar:AddSeparator()return new("Frame",{BackgroundColor3=self.Window.Theme.Border,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)},self.Frame)end
function Lunar:AddImage(data)data=data or {};local id=data.Image or data.AssetId or "";if type(id)=="number"then id="rbxassetid://"..id end;return new("ImageLabel",{BackgroundColor3=self.Window.Theme.Background,BorderSizePixel=0,Image=id,ScaleType=Enum.ScaleType.Crop,Size=UDim2.new(1,0,0,data.Height or 110)},self.Frame)end
Lunar.AddDecal=Lunar.AddImage
function Lunar:Notify(data)data=data or {};local n=new("Frame",{BackgroundColor3=self.Theme.Surface,BackgroundTransparency=self.Theme.SurfaceTransparency,BorderSizePixel=0,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-18,1,-18),Size=UDim2.fromOffset(260,64),ZIndex=150},self.Gui);corner(n,9);stroke(n,self.Theme.Border,.3);text(n,data.Title or "Lunar UI",11,self.Theme.Text,{Position=UDim2.fromOffset(13,11),Size=UDim2.new(1,-26,0,16),Font=Enum.Font.GothamBold,ZIndex=151});text(n,data.Content or "",9,self.Theme.Muted,{Position=UDim2.fromOffset(13,29),Size=UDim2.new(1,-26,0,22),TextWrapped=true,ZIndex=151});if data.Duration~=nil then task.delay(data.Duration or 4,function()if n.Parent then n:Destroy()end end)end;return n end
function Lunar:SetTheme(name)if not Themes[name]then return false end;self.Theme=Themes[name];self.ThemeName=name;self.Root.BackgroundColor3=self.Theme.Background;self.Sidebar.BackgroundColor3=self.Theme.Surface;return true end
function Lunar:SetAnimationsEnabled(enabled)Lunar.Animations=enabled~=false;return Lunar.Animations end
function Lunar:SetAnimationStyle(style)return style or "Static" end
function Lunar:SetProfileNameVisible()return false end
function Lunar:SetAnimationsEnabled(enabled)Lunar.Animations=enabled~=false;return Lunar.Animations end
function Lunar:SetAnimationStyle()return "Static" end
function Lunar:SetProfileNameVisible()return false end
function Lunar:Toggle()self.Root.Visible=not self.Root.Visible;return self.Root.Visible end
function Lunar:SelectTab(tab)if type(tab)=="number"then tab=self.Tabs[tab]end;if tab then tab:Select()end end
function Lunar:GetConfig()return HttpService:JSONEncode(self.Values)end
function Lunar:LoadConfig(config)local data=type(config)=="string"and HttpService:JSONDecode(config)or config;for key,value in pairs(data or {})do if Lunar.Options[key]then Lunar.Options[key]:SetValue(value)end end end
function Lunar:Destroy()self.Gui:Destroy()end

return Lunar
