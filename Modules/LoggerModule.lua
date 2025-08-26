--// LoggerModule.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local MarketplaceService = game:GetService("MarketplaceService")

local LoggerModule = {}

function LoggerModule.SendLog(webhookUrl)
    local player = Players.LocalPlayer
    if not player then return end

    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, _ = Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)

    local success, region = pcall(function()
        return LocalizationService:GetCountryRegionForPlayerAsync(player)
    end)
    if not success then
        region = "Unknown"
    end

    local gameName = "Unknown"
    local successGame, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if successGame and info and info.Name then
        gameName = info.Name
    end

    local timeNow = os.date("!%Y-%m-%d %H:%M:%S", os.time() + 7*60*60) .. " GMT+7"

    local embed = {
        ["title"] = "🚨 Script Executed",
        ["description"] = "**Người chơi đã chạy script!**",
        ["color"] = 16711680, -- đỏ
        ["thumbnail"] = {
            ["url"] = content
        },
        ["fields"] = {
            {
                ["name"] = "👤 Player",
                ["value"] = player.Name,
                ["inline"] = true
            },
            {
                ["name"] = "🌍 Region",
                ["value"] = region,
                ["inline"] = true
            },
            {
                ["name"] = "🎮 Game",
                ["value"] = gameName,
                ["inline"] = false
            },
            {
                ["name"] = "⏰ Time",
                ["value"] = timeNow,
                ["inline"] = false
            }
        }
    }

    local data = {
        ["embeds"] = {embed}
    }

    local jsonData = HttpService:JSONEncode(data)
    request = request or http_request or syn.request or http.request
    if request then
        request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    end
end

return LoggerModule
