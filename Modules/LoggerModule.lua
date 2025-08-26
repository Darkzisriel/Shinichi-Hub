--// LoggerModule.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local MarketplaceService = game:GetService("MarketplaceService")

local LoggerModule = {}

-- Hàm lấy request function tương thích với exploit
local function getRequest()
    return (syn and syn.request) 
        or (http and http.request) 
        or http_request 
        or request 
        or (fluxus and fluxus.request) 
        or nil
end

-- Hàm đảm bảo giá trị luôn là string
local function safeString(value)
    if value == nil then
        return "Unknown"
    end
    return tostring(value)
end

function LoggerModule.SendLog(webhookUrl)
    local player = Players.LocalPlayer
    if not player then return end

    -- Avatar roblox
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content = ""
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)
    end)
    if ok and url then
        content = url
    else
        content = "https://tr.rbxcdn.com/180-day-default.png" -- fallback
    end

    -- Lấy region
    local region = "Unknown"
    local success, result = pcall(function()
        return LocalizationService:GetCountryRegionForPlayerAsync(player)
    end)
    if success and result then
        region = result
    end

    -- Lấy tên trải nghiệm
    local gameName = "Unknown Game"
    local successGame, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if successGame and info and info.Name then
        gameName = info.Name
    end

    -- Thời gian hiện tại (UTC+7 cho Việt Nam)
    local timeNow = os.date("!%Y-%m-%d %H:%M:%S", os.time() + 7*60*60) .. " GMT+7"

    -- Embed cho Discord
    local embed = {
        ["title"] = "🚨 Script Executed",
        ["description"] = "Người chơi đã chạy script!",
        ["color"] = 16711680,
        ["thumbnail"] = { ["url"] = safeString(content) },
        ["fields"] = {
            {
                ["name"] = "👤 Player",
                ["value"] = safeString(player.Name),
                ["inline"] = true
            },
            {
                ["name"] = "🌍 Region",
                ["value"] = safeString(region),
                ["inline"] = true
            },
            {
                ["name"] = "🎮 Game",
                ["value"] = safeString(gameName),
                ["inline"] = false
            },
            {
                ["name"] = "⏰ Time",
                ["value"] = safeString(timeNow),
                ["inline"] = false
            }
        }
    }

    local data = {
        ["username"] = "Script Logger",
        ["content"] = "",
        ["embeds"] = {embed}
    }

    -- Gửi request
    local jsonData = HttpService:JSONEncode(data)
    local req = getRequest()

    if req then
        local res = req({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
        print("[LoggerModule] Status:", res.StatusCode, res.StatusMessage or "")
        if res.Body then print("[LoggerModule] Response:", res.Body) end
    else
        warn("[LoggerModule] No request function found ❌")
    end
end

return LoggerModule
