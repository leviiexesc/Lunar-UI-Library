-- Lunar UI SaveManager
-- Uses an optional storage adapter; falls back to executor file APIs when available.

local HttpService = game:GetService("HttpService")

local SaveManager = {
    Library = nil,
    Folder = "LunarUI",
    IgnoreIndexes = {},
    IgnoreThemes = false,
    Storage = nil,
}

local function path(folder, name)
    return string.format("%s/%s.json", folder, name)
end

function SaveManager:SetLibrary(library)
    self.Library = library
    return self
end

function SaveManager:SetFolder(folder)
    self.Folder = folder
    return self
end

function SaveManager:SetStorage(storage)
    -- storage must expose Read(path), Write(path, content), List(folder), and optionally Delete(path)
    self.Storage = storage
    return self
end

function SaveManager:SetIgnoreIndexes(indexes)
    self.IgnoreIndexes = {}
    for _, index in ipairs(indexes or {}) do self.IgnoreIndexes[index] = true end
    return self
end

function SaveManager:IgnoreThemeSettings()
    self.IgnoreThemes = true
    return self
end

function SaveManager:_ensureFolder()
    if self.Storage then return true end
    if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
    return type(writefile) == "function" and type(readfile) == "function"
end

function SaveManager:_read(file)
    if self.Storage then return self.Storage:Read(file) end
    if type(isfile) == "function" and not isfile(file) then return nil end
    if type(readfile) == "function" then return readfile(file) end
end

function SaveManager:_write(file, content)
    if self.Storage then return self.Storage:Write(file, content) end
    if type(writefile) == "function" then return writefile(file, content) end
    return false, "No storage adapter or file API is available."
end

function SaveManager:_values()
    assert(self.Library, "SaveManager:SetLibrary(LunarUI) must be called first.")
    local result = {}
    for key, value in pairs(self.Library.Options or {}) do
        if not self.IgnoreIndexes[key] and not (self.IgnoreThemes and key == "LunarTheme") then
            local current = value.Value
            if typeof(current) == "Color3" then
                result[key] = { __type = "Color3", r = current.R, g = current.G, b = current.B }
            elseif typeof(current) == "EnumItem" then
                result[key] = { __type = "Enum", enum = tostring(current) }
            else
                result[key] = current
            end
        end
    end
    return result
end

function SaveManager:Save(name)
    assert(type(name) == "string" and name ~= "", "A config name is required.")
    local available, reason = self:_ensureFolder()
    if not available then return false, reason end
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, { version = 1, values = self:_values() })
    if not ok then return false, encoded end
    local wrote, err = self:_write(path(self.Folder, name), encoded)
    return wrote ~= false, err
end

function SaveManager:Load(name)
    assert(self.Library, "SaveManager:SetLibrary(LunarUI) must be called first.")
    local source = self:_read(path(self.Folder, name))
    if not source then return false, "Config not found." end
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, source)
    if not ok then return false, decoded end
    for key, value in pairs(decoded.values or decoded) do
        if type(value) == "table" and value.__type == "Color3" then value = Color3.new(value.r, value.g, value.b) end
        local option = self.Library.Options and self.Library.Options[key]
        if option and option.SetValue then option:SetValue(value) end
    end
    return true
end

function SaveManager:List()
    if self.Storage then return self.Storage:List(self.Folder) end
    if type(listfiles) ~= "function" then return {} end
    local names = {}
    for _, file in ipairs(listfiles(self.Folder)) do
        local name = file:match("([^/\\]+)%.json$")
        if name and name ~= "__autoload" then table.insert(names, name) end
    end
    table.sort(names)
    return names
end

function SaveManager:SetAutoload(name)
    return self:_write(path(self.Folder, "__autoload"), name)
end

function SaveManager:LoadAutoloadConfig()
    local name = self:_read(path(self.Folder, "__autoload"))
    if not name or name == "" then return false, "No autoload config selected." end
    return self:Load(name)
end

function SaveManager:Delete(name)
    local file = path(self.Folder, name)
    if self.Storage and self.Storage.Delete then return self.Storage:Delete(file) end
    if type(delfile) == "function" and (type(isfile) ~= "function" or isfile(file)) then delfile(file); return true end
    return false, "Delete is not supported by the active storage."
end

function SaveManager:BuildConfigSection(tab)
    local section = tab:AddSection({ Title = "Configuration" })
    local input = section:AddInput("LunarConfigName", { Title = "Config name", Placeholder = "my-config", Default = "default", Finished = true })
    section:AddButton({ Title = "Save configuration", ButtonText = "Save", Callback = function() self:Save(input.Value) end })
    section:AddButton({ Title = "Load configuration", ButtonText = "Load", Callback = function() self:Load(input.Value) end })
    section:AddButton({ Title = "Set as autoload", ButtonText = "Autoload", Callback = function() self:SetAutoload(input.Value) end })
    return section
end

return SaveManager
