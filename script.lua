-- CONFIG
local config = {
    DiscordWebhook = "https://discord.com/api/webhooks/1400382842894159923/XIjGfYweEPlkU6VERCzil1lQbFfwKwbxfibXzTryFZu0I3tr4k5KuvwDcPKJhphgpHzH",
    GeneratorTime = 2.5,
    LoadTime = 2,
}

if tonumber(config.LoadTime) then
    task.wait(tonumber(config.LoadTime))
else
    repeat task.wait() until game:IsLoaded()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local Humanoid, RootPart

local ActiveInfiniteStamina = true
local ProfilePicture = ""
local AliveNotifications = {}
local DCWebhook = config.DiscordWebhook
local GenTime = config.GeneratorTime
local InGame = false

-- 🛠 UI notification
local NotificationUI = Instance.new("ScreenGui", game.CoreGui)
NotificationUI.Name = "NotificationUI"

local function MakeNotif(title, message, duration, color)
    duration = duration or 5
    color = color or Color3.fromRGB(255, 200, 0)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 250, 0, 80)
    notif.Position = UDim2.new(1, 50, 1, 10)
    notif.BackgroundColor3 = Color3.fromRGB(30,30,30)
    notif.Parent = NotificationUI
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0,8)

    local titleLabel = Instance.new("TextLabel", notif)
    titleLabel.Size = UDim2.new(1,-25,0,25)
    titleLabel.Position = UDim2.new(0,15,0,5)
    titleLabel.Text = title
    titleLabel.TextColor3 = color
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local msgLabel = Instance.new("TextLabel", notif)
    msgLabel.Size = UDim2.new(1,-25,0,50)
    msgLabel.Position = UDim2.new(0,15,0,30)
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.new(1,1,1)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Font = Enum.Font.SourceSans
    msgLabel.TextSize = 16
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true

    table.insert(AliveNotifications, {Instance=notif,Expire=os.time()+duration})
    TweenService:Create(notif, TweenInfo.new(0.5), {Position=UDim2.new(1,-270,1,-90-#AliveNotifications*90)}):Play()

    task.spawn(function()
        task.wait(duration)
        TweenService:Create(notif, TweenInfo.new(0.5), {Position=UDim2.new(1,50,notif.Position.Y.Scale,notif.Position.Y.Offset)}):Play()
        task.wait(0.5)
        notif:Destroy()
    end)
end

-- 🌱 Infinite stamina
task.spawn(function()
    while ActiveInfiniteStamina do
        pcall(function()
            local m=require(game.ReplicatedStorage.Systems.Character.Game.Sprinting)
            m.StaminaLossDisabled=true
            m.Stamina=999999
        end)
        task.wait(0.1)
    end
end)

-- 📨 Get avatar
task.spawn(function()
    local req = request or http_request or syn.request
    if req then
        local r=req({Url="https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..player.UserId.."&size=180x180&format=png",Method="GET"})
        if r and r.Body then
            local data=HttpService:JSONDecode(r.Body)
            if data and data.data and data.data[1] then
                ProfilePicture=data.data[1].imageUrl
            end
        end
    end
end)

-- 📨 Send webhook
local function SendWebhook(title,desc,color)
    local req = request or http_request or syn.request
    if DCWebhook and req then
        req({
            Url=DCWebhook, Method="POST",
            Headers={["Content-Type"]="application/json"},
            Body=HttpService:JSONEncode({
                username=player.DisplayName, avatar_url=ProfilePicture,
                embeds={{title=title,description=desc,color=color}}
            })
        })
    end
end

-- 🔍 Find generators
local function findGenerators()
    local gens={}
    local folder=workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
    if folder and folder:FindFirstChild("Map") then
        for _,g in ipairs(folder.Map:GetChildren()) do
            if g.Name=="Generator" and g.Progress.Value<100 then
                table.insert(gens,g)
            end
        end
    end
    table.sort(gens,function(a,b)
        return (a:GetPivot().Position - RootPart.Position).Magnitude < (b:GetPivot().Position - RootPart.Position).Magnitude
    end)
    return gens
end

-- 🏃 Pathfinding
local function goToGenerator(gen)
    local path=PathfindingService:CreatePath({AgentRadius=2.5,AgentHeight=1,AgentCanJump=false})
    path:ComputeAsync(RootPart.Position, gen:GetPivot().Position)
    if path.Status~=Enum.PathStatus.Success then return false end
    for _,wp in ipairs(path:GetWaypoints()) do
        Humanoid:MoveTo(wp.Position)
        local t0=tick()
        repeat task.wait() until (RootPart.Position - wp.Position).Magnitude<5 or tick()-t0>3
        if tick()-t0>3 then return false end
    end
    return true
end

-- 🔀 Hop server
local function hopServer()
    local req = request or http_request or syn.request
    if req then
        local r=req({Url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100",Method="GET"})
        if r and r.Body then
            local data=HttpService:JSONDecode(r.Body)
            for _,s in pairs(data.data) do
                if s.playing<s.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,player)
                    return
                end
            end
        end
    end
end

-- ⚡ Teleport farthest gen if low HP
task.spawn(function()
    while task.wait(1) do
        if InGame and Humanoid and Humanoid.Health<50 then
            local gens=findGenerators()
            if #gens>0 then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(gens[#gens]:GetPivot().Position+Vector3.new(0,2,0))
                MakeNotif("Escape","TP to far generator",3,Color3.fromRGB(255,0,0))
            end
        end
    end
end)

-- 🧰 Auto farm generators
local function doGenerators()
    local gens=findGenerators()
    for _,g in ipairs(gens) do
        if goToGenerator(g) then
            task.wait(0.2)
            if g:FindFirstChild("Main") and g.Main:FindFirstChild("Prompt") then
                fireproximityprompt(g.Main.Prompt)
            end
            for i=1,6 do
                if g:FindFirstChild("Remotes") and g.Remotes:FindFirstChild("RE") then
                    g.Remotes.RE:FireServer()
                end
                if g.Progress.Value>=100 then break end
                task.wait(GenTime)
            end
        else
            MakeNotif("Pathfail","Hop server",3,Color3.fromRGB(255,0,0))
            hopServer()
            break
        end
    end
    SendWebhook("Done","Finished all generators!",0x00ff00)
end

-- 🪦 On death → hop server
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        SendWebhook("Dead","Hopping server...",0xff0000)
        hopServer()
    end)
end)

-- 🎮 Check if in game
workspace.Players.Survivors.ChildAdded:Connect(function(child)
    if child==player.Character then
        task.wait(3)
        Humanoid=player.Character:WaitForChild("Humanoid")
        RootPart=player.Character:WaitForChild("HumanoidRootPart")
        InGame=true
        doGenerators()
    end
end)

-- ✅ Start
MakeNotif("AutoFarm","Loaded!",3,Color3.fromRGB(0,255,0))
SendWebhook("AutoFarm Started","Ready!",0x00ff00)
