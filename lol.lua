-- Wait game load
while not game:IsLoaded() do task.wait() end

local PFS = game:GetService("PathfindingService")
local VIM = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local isInGame, currentCharacter, stamina, busy, isSprinting = false, nil, 0, false, false

local function PathfindToTarget(targetPosition)
    local character = Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character.HumanoidRootPart

    local path = PFS:CreatePath({AgentRadius=2.5,AgentHeight=1,AgentCanJump=false})
    local success, err = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)
    if not success or path.Status ~= Enum.PathStatus.Success then
        warn("Failed to compute path:", err)
        return false
    end

    for _, waypoint in ipairs(path:GetWaypoints()) do
        humanoid:MoveTo(waypoint.Position)
        local reached = false
        local conn = humanoid.MoveToFinished:Connect(function(s)
            reached = s
            conn:Disconnect()
        end)
        local startTime = tick()
        repeat task.wait(0.01) until reached or (tick()-startTime)>=10
        if not reached then
            warn("Failed to reach waypoint, stop path.")
            return false
        end
    end
    return true
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

local function findGenerators()
    local gens = {}
    local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
    local map = folder and folder:FindFirstChild("Map")
    if map then
        for _, g in ipairs(map:GetChildren()) do
            if g.Name=="Generator" and g.Progress.Value<100 then
                table.insert(gens, g)
            end
        end
    end
    table.sort(gens,function(a,b)
        local root = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        return (a:GetPivot().Position - root.Position).Magnitude < (b:GetPivot().Position - root.Position).Magnitude
    end)
    return gens
end

local function DoAllGenerators()
    for _, g in ipairs(findGenerators()) do
        local killer = getValidTarget()
        if killer and (Players.LocalPlayer.Character:GetPivot().Position - killer.Position).Magnitude <=80 then
            local awayPos = Players.LocalPlayer.Character:GetPivot().Position + (Players.LocalPlayer.Character:GetPivot().Position - killer.Position).Unit*80
            local success = PathfindToTarget(awayPos)
            if not success then
                local away = (Players.LocalPlayer.Character:GetPivot().Position - killer.Position).Unit*30
                Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Players.LocalPlayer.Character:GetPivot().Position+away)
            end
            task.wait(0.5)
        end

        local genPos = g:GetPivot().Position + g:GetPivot().LookVector*3
        local pathStarted = PathfindToTarget(genPos)
        if pathStarted then
            task.wait(0.5)
            local prompt = g:FindFirstChild("Main") and g.Main:FindFirstChild("Prompt")
            if prompt then
                fireproximityprompt(prompt)
                task.wait(0.5)
            end
            for i=1,6 do
                local killer = getValidTarget()
                if killer and (Players.LocalPlayer.Character:GetPivot().Position - killer.Position).Magnitude <=80 then
                    local awayPos = Players.LocalPlayer.Character:GetPivot().Position + (Players.LocalPlayer.Character:GetPivot().Position - killer.Position).Unit*80
                    local success = PathfindToTarget(awayPos)
                    if not success then
                        local away = (Players.LocalPlayer.Character:GetPivot().Position - killer.Position).Unit*30
                        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Players.LocalPlayer.Character:GetPivot().Position+away)
                    end
                    task.wait(0.5)
                end
                if g.Progress.Value<100 and g:FindFirstChild("Remotes") and g.Remotes:FindFirstChild("RE") then
                    g.Remotes.RE:FireServer()
                end
                if i<6 and g.Progress.Value<100 then
                    task.wait(2.5)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        if isInGame then
            local barText = Players.LocalPlayer.PlayerGui.TemporaryUI.PlayerInfo.Bars.Stamina.Amount.Text
            stamina = tonumber(string.split(barText,"/")[1])
            if not isSprinting and stamina>=40 and not busy then
                VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
            end
        end
        wait(1)
    end
end)

task.spawn(function()
    while true do
        local spectators = {}
        for _, child in ipairs(workspace.Players.Spectating:GetChildren()) do
            table.insert(spectators, child.Name)
        end
        isInGame = not table.find(spectators, Players.LocalPlayer.Name)
        wait(1)
    end
end)

task.spawn(function()
    wait(20*60)
    TeleportService:Teleport(game.PlaceId)
end)

workspace.Players.Survivors.ChildAdded:Connect(function(child)
    task.wait(1)
    if child==Players.LocalPlayer.Character then
        currentCharacter=child
        task.wait(4)
        DoAllGenerators()
    end
end)
