-- Lunar UI LicenseManager
-- Requires a deployed license-server URL. The server binds one key to one device ID.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LicenseManager = {
    Endpoint = "https://YOUR-LICENSE-SERVER.example.com",
}

local function requestFunction()
    return request or http_request or (syn and syn.request) or (http and http.request)
end

function LicenseManager:SetEndpoint(endpoint)
    assert(type(endpoint) == "string" and endpoint ~= "", "A license server endpoint is required.")
    self.Endpoint = endpoint:gsub("/$", "")
    return self
end

function LicenseManager:GetDeviceId()
    local environment = type(getgenv) == "function" and getgenv() or _G
    if type(environment.HWID) == "string" and environment.HWID ~= "" then return environment.HWID end
    local ok, clientId = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if ok and clientId and clientId ~= "" then return clientId end
    return game:GetService("Players").LocalPlayer.UserId .. ":" .. game.PlaceId
end

function LicenseManager:Validate(key)
    assert(type(key) == "string" and key ~= "", "A license key is required.")
    local requester = requestFunction()
    if not requester then return false, "No HTTP request function is available." end
    local ok, result = pcall(requester, {
        Url = self.Endpoint .. "/validate",
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({ key = key, hwid = self:GetDeviceId() }),
    })
    if not ok or not result then return false, "License server request failed." end
    local decodedOk, decoded = pcall(HttpService.JSONDecode, HttpService, result.Body or "{}")
    if not decodedOk then return false, "License server returned invalid data." end
    return decoded.ok == true, decoded.error or decoded.message
end

function LicenseManager:ValidateOrKick(key)
    local valid, message = self:Validate(key)
    if not valid then
        local player = Players.LocalPlayer
        if player then player:Kick(message or "License validation failed.") end
        return false, message
    end
    return true
end

return LicenseManager
