if getgenv and tonumber(getgenv().LoadTime) then
    task.wait(tonumber(getgenv().LoadTime))
else
    repeat task.wait() until game:IsLoaded()
end

local VIMVIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DCWebhook = (getgenv and getgenv().DiscordWebhook) or false
local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5

local ProfilePicture = ""

if DCWebhook == "" then
    DCWebhook = false
end

local function GetProfilePicture()
    local PlayerID = Players.LocalPlayer.UserId
    local request = request or http_request or syn.request
    local response = request({
        Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..PlayerID.."&size=180x180&format=png",
        Method = "GET",
        Headers = { ["User-Agent"] = "Mozilla/5.0" }
    })
    local urlStart, urlEnd = string.find(response.Body, "https://[%w-_%.%?%.:/%+=&]+")
    if urlStart and urlEnd then
        ProfilePicture = string.sub(response.Body, urlStart, urlEnd)
    else
        ProfilePicture = "https://cdn.sussy.dev/bleh.jpg"
    end
end

if DCWebhook then
    GetProfilePicture()
end

local function SendWebhook(Title, Description, Color)
    if not DCWebhook then return end
    local request = request or http_request or syn.request
    if not request then return end
    local data = {
        username = Players.LocalPlayer.DisplayName,
        avatar_url = ProfilePicture,
        embeds = {
            {
                title = Title,
                description = Description,
                color = Color,
                footer = { text = "Legit Auto By Darkz" }
            }
        }
    }
    local success, res = pcall(function()
        request({
            Url = DCWebhook,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        })
    end)
end

local function teleportToRandomServer()
    local Counter = 0
    local MaxRetry = 10
    local Request = request or http_request or syn.request
    while Counter < MaxRetry do
        local success, response = pcall(function()
            return Request({
                Url = "https://games.roblox.com/v1/games/18687417158/servers/Public?sortOrder=Asc&limit=100",
                Method = "GET",
                Headers = { ["Content-Type"] = "application/json" }
            })
        end)
        if success and response and response.Body then
            local data = HttpService:JSONDecode(response.Body)
            if data and data.data and #data.data > 0 then
                local server = data.data[math.random(1, #data.data)]
                if server.id then
                    TeleportService:TeleportToPlaceInstance(18687417158, server.id, Players.LocalPlayer)
                    return
                end
            end
        end
        Counter = Counter + 1
        task.wait(10)
    end
end

local function findGenerators()
    local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
    local map = folder and folder:FindFirstChild("Map")
    local generators = {}
    if map then
        for _, g in ipairs(map:GetChildren()) do
            if g.Name == "Generator" and g.Progress.Value < 100 then
                local playersNearby = false
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= Players.LocalPlayer and player:DistanceFromCharacter(g:GetPivot().Position) <= 25 then
                        playersNearby = true
                    end
                end
                if not playersNearby then
                    table.insert(generators, g)
                end
            end
        end
    end
    table.sort(generators, function(a, b)
        local rootPart = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return false end
        return (a:GetPivot().Position - rootPart.Position).Magnitude < (b:GetPivot().Position - rootPart.Position).Magnitude
    end)
    return generators
end

local function getValidTarget()
    local killerFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if killerFolder then
        for _, killer in ipairs(killerFolder:GetChildren()) do
            if killer:FindFirstChild("HumanoidRootPart") then
                return killer.HumanoidRootPart
            end
        end
    end
    return nil
end

local function PathFinding(generator)
    if not generator or not generator.Parent then return false end
    local character = Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local rootPart = character.HumanoidRootPart
    local targetPosition = generator:GetPivot().Position + generator:GetPivot().LookVector * 3
    local path = PathfindingService:CreatePath({ AgentRadius = 2.5, AgentHeight = 1, AgentCanJump = false })
    local success = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)
    if not success or path.Status ~= Enum.PathStatus.Success then return false end
    local waypoints = path:GetWaypoints()
    if #waypoints <= 1 then return false end
    for _, waypoint in ipairs(waypoints) do
        humanoid:MoveTo(waypoint.Position)
        local reached = false
        local startTime = tick()
        while not reached and tick() - startTime < 5 do
            if (rootPart.Position - waypoint.Position).Magnitude < 5 then
                reached = true
            end
            RunService.Heartbeat:Wait()
        end
        if not reached then return false end
    end
    return true
end

local function DoAllGenerators()
    for _, g in ipairs(findGenerators()) do
        local killer = getValidTarget()
        if killer and (Players.LocalPlayer.Character:GetPivot().Position - killer.Position).Magnitude <= 80 then
            local away = (Players.LocalPlayer.Character:GetPivot().Position - killer.Position).Unit * 30
            Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Players.LocalPlayer.Character:GetPivot().Position + away)
            task.wait(0.5)
        end
        local pathStarted = PathFinding(g)
        if pathStarted then
            task.wait(0.5)
            local prompt = g:FindFirstChild("Main") and g.Main:FindFirstChild("Prompt")
            if prompt then
                fireproximityprompt(prompt)
                task.wait(0.5)
            end
            for i = 1, 6 do
                local killer = getValidTarget()
                if killer and (Players.LocalPlayer.Character:GetPivot().Position - killer.Position).Magnitude <= 80 then
                    local away = (Players.LocalPlayer.Character:GetPivot().Position - killer.Position).Unit * 30
                    Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Players.LocalPlayer.Character:GetPivot().Position + away)
                    task.wait(0.5)
                end
                if g.Progress.Value < 100 and g:FindFirstChild("Remotes") and g.Remotes:FindFirstChild("RE") then
                    g.Remotes.RE:FireServer()
                end
                if i < 6 and g.Progress.Value < 100 then
                    task.wait(GenTime)
                end
            end
        else
            return
        end
    end
    SendWebhook("Generator Autofarm", "Finished all generators.", 0x00FF00)
    task.wait(1)
    teleportToRandomServer()
end

local function AmIInGameYet()
    workspace.Players.Survivors.ChildAdded:Connect(function(child)
        task.wait(1)
        if child == Players.LocalPlayer.Character then
            task.wait(4)
            DoAllGenerators()
        end
    end)
end

local function DidiDie()
    while task.wait(0.5) do
        if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            if Players.LocalPlayer.Character.Humanoid.Health == 0 then
                SendWebhook("Generator Autofarm", "Died, teleporting.", 0xFF0000)
                task.wait(0.5)
                teleportToRandomServer()
                break
            end
        end
    end
end

task.spawn(DidiDie)
AmIInGameYet()
