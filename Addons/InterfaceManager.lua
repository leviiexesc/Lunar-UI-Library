-- Lunar UI InterfaceManager
-- Adds common appearance and interface preferences to a settings tab.

local InterfaceManager = {
    Library = nil,
    Folder = "LunarUI",
    Window = nil,
}

function InterfaceManager:SetLibrary(library)
    self.Library = library
    return self
end

function InterfaceManager:SetFolder(folder)
    self.Folder = folder
    return self
end

function InterfaceManager:SetWindow(window)
    self.Window = window
    return self
end

function InterfaceManager:BuildInterfaceSection(tab, window)
    window = window or self.Window
    assert(window, "Pass a Lunar UI window or call InterfaceManager:SetWindow(window).")
    local section = tab:AddSection({ Title = "Interface" })
    section:AddDropdown("LunarTheme", {
        Title = "Theme",
        Description = "Choose your preferred Lunar UI appearance.",
        Values = { "Dark", "Light" },
        Default = window.ThemeName,
        Callback = function(theme) window:SetTheme(theme) end,
    })
    section:AddToggle("LunarAnimations", {
        Title = "Smooth animations",
        Description = "Use tweens when opening, closing, and changing controls.",
        Default = self.Library and self.Library.AnimationsEnabled ~= false,
        Callback = function(enabled)
            if self.Library then self.Library:SetAnimationsEnabled(enabled) end
        end,
    })
    section:AddDropdown("LunarMotionStyle", {
        Title = "Motion style",
        Description = "Fluid uses a subtle mobile-style spring effect.",
        Values = { "Fluid", "Soft", "Fast" },
        Default = self.Library and self.Library.AnimationStyle or "Fluid",
        Callback = function(style)
            if self.Library then self.Library:SetAnimationStyle(style) end
        end,
    })
    section:AddToggle("LunarProfileNames", {
        Title = "Show profile name",
        Description = "Show your DisplayName and @Username beside the avatar.",
        Default = true,
        Callback = function(visible)
            window:SetProfileNameVisible(visible)
        end,
    })
    section:AddKeybind("LunarToggleKey", {
        Title = "Toggle interface",
        Description = "Show or hide the Lunar UI window.",
        Default = "RightControl",
        Mode = "Toggle",
        Callback = function() window:Toggle() end,
    })
    section:AddButton({
        Title = "Reset appearance",
        ButtonText = "Reset",
        Callback = function()
            window:SetTheme("Dark")
            local theme = self.Library and self.Library.Options and self.Library.Options.LunarTheme
            if theme then theme:SetValue("Dark") end
        end,
    })
    return section
end

return InterfaceManager
