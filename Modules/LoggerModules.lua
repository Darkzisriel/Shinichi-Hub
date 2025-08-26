--// LoggerModule.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local MarketplaceService = game:GetService("MarketplaceService")

local LoggerModule = {}
local ProfilePicture = "https://cdn.sussy.dev/bleh.jpg" -- fallback

local function GetProfilePicture()
    local PlayerID = Players.LocalPlayer.UserId
    local req = request or http_request or syn.request
    if not req then return end

    local res = req({
        Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. PlayerID .. "&size=180x180&format=png",
        Method = "GET"
    })

    local start, finish = string.find(res.Body, "https://[%w-_%.%?%.:/%+=&]+")
    if start and finish then
        ProfilePicture = string.sub(res.Body, start, finish)
    end
end

function LoggerModule.SendLog(webhookUrl)
    if not webhookUrl then return end
    GetProfilePicture()

    local player = Players.LocalPlayer
    local region = "Unknown"
    pcall(function()
        region = LocalizationService:GetCountryRegionForPlayerAsync(player)
    end)

    local gameName = "Unknown Game"
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if info and info.Name then
            gameName = info.Name
        end
    end)

    local timeNow = os.date("!%Y-%m-%d %H:%M:%S", os.time() + 7*60*60) .. " GMT+7"

    local desc = table.concat({
        "👤 **Player:** " .. player.Name,
        "🌍 **Region:** " .. region,
        "🎮 **Game:** " .. gameName,
        "⏰ **Time:** " .. timeNow
    }, "\n")

    local req = request or http_request or syn.request
    if not req then return end

    local success, msg = pcall(function()
        req({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                username = player.DisplayName,
                avatar_url = ProfilePicture,
                embeds = {{
                    title = "🚨 Script Executed",
                    description = desc,
                    color = 16711680,
                    footer = {text = "Script Logger"}
                }}
            })
        })
    end)

    if not success then
        warn("Webhook failed: " .. msg)
    end
end

return LoggerModule

