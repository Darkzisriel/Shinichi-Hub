if getgenv and tonumber(getgenv().LoadTime) then
	task.wait(tonumber(getgenv().LoadTime))
else
	repeat task.wait() until game:IsLoaded()
end

local VIMVIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local lp = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local DCWebhook = (getgenv and getgenv().DiscordWebhook) or false
local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5

local AliveNotificaiotna, Nnnnnnotificvationui, ProfilePicture = {}, nil, ""
if DCWebhook == "" then DCWebhook = false end

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local blur = Instance.new("BlurEffect")
blur.Name = "CrystalBlur"
blur.Size = 25
blur.Parent = Lighting

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CrystalHub"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local container = Instance.new("Frame")
container.Size = UDim2.new(0.9, 0, 0.5, 0) -- chiếm 90% chiều ngang, 50% chiều dọc
container.Position = UDim2.new(0.5, 0, 0.5, 0)
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.BackgroundTransparency = 1
container.Parent = screenGui

local mainFont = Enum.Font.FredokaOne
local white = Color3.new(1, 1, 1)
local blue = Color3.fromRGB(60, 100, 255)

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0.25, 0, 0.4, 0) -- logo chiếm 25% ngang, 40% cao
logo.Position = UDim2.new(0.5, 0, 0, -50)
logo.AnchorPoint = Vector2.new(0.5, 0)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://129781592728096"
logo.Parent = container

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.12, 0)
title.Position = UDim2.new(0, 0, 0.35, 0)
title.BackgroundTransparency = 1
title.TextColor3 = blue
title.TextScaled = true
title.Font = mainFont
title.Text = "Crystal Hub - AutoFarm Forsaken [Blatant]"
title.Parent = container

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0.1, 0)
status.Position = UDim2.new(0, 0, 0.5, 0)
status.BackgroundTransparency = 1
status.TextColor3 = white
status.TextScaled = true
status.Font = mainFont
status.Text = "Status : Farming"
status.Parent = container

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(1, 0, 0.1, 0)
moneyLabel.Position = UDim2.new(0, 0, 0.62, 0)
moneyLabel.BackgroundTransparency = 1
moneyLabel.TextColor3 = white
moneyLabel.TextScaled = true
moneyLabel.Font = mainFont
moneyLabel.Text = "Money : 0"
moneyLabel.Parent = container

local playTime = Instance.new("TextLabel")
playTime.Size = UDim2.new(1, 0, 0.1, 0)
playTime.Position = UDim2.new(0, 0, 0.74, 0)
playTime.BackgroundTransparency = 1
playTime.TextColor3 = white
playTime.TextScaled = true
playTime.Font = mainFont
playTime.Text = "Play Time : 00 Hours 00 Minutes 00 Seconds"
playTime.Parent = container

local discord = Instance.new("TextLabel")
discord.Size = UDim2.new(1, 0, 0.1, 0)
discord.Position = UDim2.new(0, 0, 0.86, 0)
discord.BackgroundTransparency = 1
discord.TextColor3 = white
discord.TextScaled = true
discord.Font = mainFont
discord.Text = "discord.gg/fRz66wAuUS"
discord.Parent = container

local discordLinkButton = Instance.new("TextButton")
discordLinkButton.Size = UDim2.new(0.5, 0, 0.12, 0) -- nút chiếm nửa ngang
discordLinkButton.Position = UDim2.new(0.5, 0, 1.02, 0)
discordLinkButton.AnchorPoint = Vector2.new(0.5, 0)
discordLinkButton.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
discordLinkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
discordLinkButton.TextScaled = true
discordLinkButton.Font = mainFont
discordLinkButton.Text = "COPY LINK"
discordLinkButton.Parent = container

local discordLink = "https://discord.gg/fRz66wAuUS"
discordLinkButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(discordLink)
        discordLinkButton.Text = "COPIED!"
        task.wait(1)
        discordLinkButton.Text = "COPY LINK"
    end
end)

local startTime = tick()
task.spawn(function()
    while true do
        task.wait(1)
        local elapsed = math.floor(tick() - startTime)
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = elapsed % 60
        playTime.Text = string.format("Play Time : %02d Hours %02d Minutes %02d Seconds", h, m, s)

        local success, money = pcall(function()
            return LocalPlayer.PlayerData.Stats.Currency.Money.Value
        end)
        if success then
            moneyLabel.Text = "Money : " .. tostring(money)
        end
    end
end)


local function CreateNotificationUI()
	if Nnnnnnotificvationui then return Nnnnnnotificvationui end
	Nnnnnnotificvationui = Instance.new("ScreenGui")
	Nnnnnnotificvationui.Name = "NotificationUI"
	Nnnnnnotificvationui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Nnnnnnotificvationui.Parent = game:GetService("CoreGui")
	return Nnnnnnotificvationui
end

local function MakeNotif(title, message, duration, color)
	local ui = CreateNotificationUI()
	title = title or "Notification"
	message = message or ""
	duration = duration or 5
	color = color or Color3.fromRGB(255, 200, 0)
	local notification = Instance.new("Frame")
	notification.Name = "Notification"
	notification.Size = UDim2.new(0, 250, 0, 80)
	notification.Position = UDim2.new(1, 50, 1, 10)
	notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	notification.BorderSizePixel = 0
	notification.Parent = ui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notification
	local SIGMABERFIOENEW = Instance.new("TextLabel")
	SIGMABERFIOENEW.Name = "Title"
	SIGMABERFIOENEW.Size = UDim2.new(1, -25, 0, 25)
	SIGMABERFIOENEW.Position = UDim2.new(0, 15, 0, 5)
	SIGMABERFIOENEW.Font = Enum.Font.SourceSansBold
	SIGMABERFIOENEW.Text = title
	SIGMABERFIOENEW.TextSize = 18
	SIGMABERFIOENEW.TextColor3 = color
	SIGMABERFIOENEW.BackgroundTransparency = 1
	SIGMABERFIOENEW.TextXAlignment = Enum.TextXAlignment.Left
	SIGMABERFIOENEW.Parent = notification
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "Message"
	messageLabel.Size = UDim2.new(1, -25, 0, 50)
	messageLabel.Position = UDim2.new(0, 15, 0, 30)
	messageLabel.Font = Enum.Font.SourceSans
	messageLabel.Text = message
	messageLabel.TextSize = 16
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.BackgroundTransparency = 1
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextWrapped = true
	messageLabel.Parent = notification
	local colorBar = Instance.new("Frame")
	colorBar.Name = "ColorBar"
	colorBar.Size = UDim2.new(0, 5, 1, 0)
	colorBar.Position = UDim2.new(0, 0, 0, 0)
	colorBar.BackgroundColor3 = color
	colorBar.BorderSizePixel = 0
	colorBar.Parent = notification
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 8)
	barCorner.Parent = colorBar
	local offsit = 0
	for _, notif in pairs(AliveNotificaiotna) do
		if notif.Instance and notif.Instance.Parent then
			offsit = offsit + notif.Instance.Size.Y.Offset + 10
		end
	end
	local tagit = UDim2.new(1, -270, 1, -90 - offsit)
	table.insert(AliveNotificaiotna, {
		Instance = notification,
		ExpireTime = os.time() + duration,
	})
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local ok = game:GetService("TweenService"):Create(notification, tweenInfo, { Position = tagit })
	ok:Play()
	task.spawn(function()
		task.wait(duration)
		local tweenOut = game:GetService("TweenService"):Create(
			notification,
			TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{ Position = UDim2.new(1, 50, notification.Position.Y.Scale, notification.Position.Y.Offset) }
		)
		tweenOut:Play()
		tweenOut.Completed:Wait()
		for i, notif in pairs(AliveNotificaiotna) do
			if notif.Instance == notification then
				table.remove(AliveNotificaiotna, i)
				break
			end
		end
		notification:Destroy()
		task.wait()
		local currentOffset = 0
		for _, notif in pairs(AliveNotificaiotna) do
			if notif.Instance and notif.Instance.Parent then
				game:GetService("TweenService")
					:Create(
						notif.Instance,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Position = UDim2.new(1, -270, 1, -90 - currentOffset) }
					)
					:Play()
				currentOffset = currentOffset + notif.Instance.Size.Y.Offset + 10
			end
		end
	end)
	return notification
end

task.spawn(function()
	while task.wait(1) do
		local currentTime = os.time()
		local reposition = false
		for i = #AliveNotificaiotna, 1, -1 do
			local notif = AliveNotificaiotna[i]
			if currentTime > notif.ExpireTime and notif.Instance and notif.Instance.Parent then
				notif.Instance:Destroy()
				table.remove(AliveNotificaiotna, i)
				reposition = true
			end
		end
		if reposition then
			local currentOffset = 0
			for _, notif in pairs(AliveNotificaiotna) do
				if notif.Instance and notif.Instance.Parent then
					notif.Instance.Position = UDim2.new(1, -270, 1, -90 - currentOffset)
					currentOffset = currentOffset + notif.Instance.Size.Y.Offset + 10
				end
			end
		end
	end
end)

MakeNotif("Crystal Hub", "Script Loaded!", 5, Color3.fromRGB(115, 194, 89))

task.spawn(function()
	pcall(function()
		game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer(
			"UpdateSettings",
			game:GetService("Players").LocalPlayer.PlayerData.Settings.Game.MaliceDisabled,
			true
		)
	end)
end)

local TargetIds = {
    ["rbxassetid://119181003138006"] = true,
    ["rbxassetid://131430497821198"] = true,
    ["rbxassetid://138754221537146"] = true,
    ["rbxassetid://109130982296927"] = true
}


local killerAnims = {
	"126830014841198", "126355327951215", "121086746534252", "18885909645",
	"98456918873918", "105458270463374", "83829782357897", "125403313786645",
	"118298475669935", "82113744478546", "70371667919898", "99135633258223",
	"97167027849946", "109230267448394", "139835501033932", "126896426760253",
	"109667959938617", "126681776859538", "129976080405072", "121293883585738"
}

local directions = {"Left", "Right", "Forward", "Backward"}
local currentDirection = 1
local ultraInstinctEnabled = true 
local canDodge = true
local lastNotifTime = 0
local notifCooldown = 2
local dodgeDistance = 20 

local dodgeAnims = {
	Left = "rbxassetid://17096325697",
	Right = "rbxassetid://17096327600",
	Forward = "rbxassetid://17096329187",
	Backward = "rbxassetid://17096330733",
}

local function notify(msg)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Crystal Hub",
			Text = msg,
			Duration = 2
		})
	end)
end

local function playDodge()
	if not canDodge then return end
	canDodge = false

	local char = lp.Character
	if not char then 
		canDodge = true
		return 
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then 
		canDodge = true
		return 
	end

	local dir = directions[currentDirection]
	local offset = Vector3.new(0, 0, 0) -- Initialize as Vector3
	
	local currentCFrame = hrp.CFrame
	
	if dir == "Left" then
		offset = -currentCFrame.RightVector * dodgeDistance
	elseif dir == "Right" then
		offset = currentCFrame.RightVector * dodgeDistance
	elseif dir == "Forward" then
		offset = currentCFrame.LookVector * dodgeDistance
	elseif dir == "Backward" then
		offset = -currentCFrame.LookVector * dodgeDistance
	end

	if typeof(offset) ~= "Vector3" then
		offset = Vector3.new(0, 0, 0)
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = dodgeAnims[dir]
	local track = hum:LoadAnimation(anim)
	track:Play()

	local newPosition = hrp.Position + offset
	char:PivotTo(CFrame.new(newPosition))

	task.delay(0.1, function()
		canDodge = true
	end)
end
local heartbeatConnection
local function startDetection()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not ultraInstinctEnabled then return end
		local char = lp.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then return end
		local radius = 25

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local dist = (plr.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
				if dist <= radius then
					local hum = plr.Character:FindFirstChildOfClass("Humanoid")
					local animator = hum and hum:FindFirstChildOfClass("Animator")
					if animator then
						for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
							local animObj = track.Animation
							if animObj and animObj.AnimationId then
								local animId = tostring(animObj.AnimationId):match("%d+")
								if animId and table.find(killerAnims, animId) then
									if tick() - lastNotifTime >= notifCooldown then
										lastNotifTime = tick()
									end
									if canDodge then
										playDodge()
									end
									return
								end
							end
						end
					end
				end
			end
		end
	end)
end

local function stopDetection()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function GetProfilePicture()
	local PlayerID = Players.LocalPlayer.UserId
	local req = request or http_request or syn.request
	local res = req({Url="https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..PlayerID.."&size=180x180&format=png",Method="GET"})
	local start, end_ = string.find(res.Body, "https://[%w-_%.%?%.:/%+=&]+")
	if start and end_ then ProfilePicture = string.sub(res.Body,start,end_) else ProfilePicture = "https://cdn.sussy.dev/bleh.jpg" end
end

if DCWebhook then GetProfilePicture() end

local function SendWebhook(title, desc, color, pfp, footer)
	if not DCWebhook then return end
	local req = request or http_request or syn.request
	local success,msg = pcall(function()
		req({
			Url=DCWebhook, Method="POST",
			Headers={["Content-Type"]="application/json"},
			Body=HttpService:JSONEncode({
				username=Players.LocalPlayer.DisplayName, avatar_url=pfp,
				embeds={{title=title,description=desc,color=color,footer={text=footer}}}
			})
		})
	end)
	if not success then print("Webhook failed: "..msg) end
end

local function VisualizePivot(model)
    local pivot = model:GetPivot()
    if not pivot then
        warn("Model has no pivot")
        return
    end
    for i, dir in ipairs({
        { pivot.LookVector, Color3.fromRGB(0, 255, 0), "Front" },
        { -pivot.LookVector, Color3.fromRGB(255, 0, 0), "Back" },
        { pivot.RightVector, Color3.fromRGB(255, 255, 0), "Right" },
        { -pivot.RightVector, Color3.fromRGB(0, 0, 255), "Left" },
    }) do
        if typeof(dir[1]) == "Vector3" then
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.Anchored = true
            part.CanCollide = false
            part.Color = dir[2]
            part.Name = dir[3]
            part.Position = pivot.Position + dir[1] * 5
            part.Parent = workspace
        else
            warn("Invalid direction vector for " .. dir[3])
        end
    end
end

local function teleportToRandomServer()
	local Counter, MaxRetry, RetryDelay = 0, 10, 10
	local req = http_request or request or syn.request
	if req then
		local url = "https://games.roblox.com/v1/games/18687417158/servers/Public?sortOrder=Asc&limit=100"
		while Counter < MaxRetry do
			local succ, res = pcall(function() return req({Url = url, Method = "GET"}) end)
			if succ and res and res.Body then
				local data = HttpService:JSONDecode(res.Body)
				if data and data.data and #data.data > 0 then
					for _, server in ipairs(data.data) do
						if server.id and server.playing < server.maxPlayers then
							MakeNotif("Teleporting..", "Server: "..server.id, 5, Color3.fromRGB(115,194,89))
							local success, err = pcall(function()
								TeleportService:TeleportToPlaceInstance(18687417158, server.id, Players.LocalPlayer)
							end)
							if success then
								return
							else
								MakeNotif("Teleport failed", tostring(err), 5, Color3.fromRGB(255,0,0))
							end
						end
					end
				end
			end
			Counter = Counter + 1
			MakeNotif("Retrying", "Attempt "..Counter, 5, Color3.fromRGB(255,0,0))
			task.wait(RetryDelay)
		end
	end
end

TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
	MakeNotif("Teleport Failed", tostring(errorMessage or teleportResult), 5, Color3.fromRGB(255,0,0))
	task.wait(1)
	teleportToRandomServer()
end)

game.CoreGui.ChildAdded:Connect(function(child)
	if child:IsA("ScreenGui") then
		local childName = child.Name:lower()
		if string.find(childName, "kick") or string.find(childName, "error") or 
		   string.find(childName, "ban") or string.find(childName, "disconnect") or
		   string.find(childName, "boot") then
			MakeNotif("Kicked/Error Detected", "Auto-hopping to new server...", 5, Color3.fromRGB(255,0,0))
			task.wait(1)
			teleportToRandomServer()
		end
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	if player == Players.LocalPlayer then
		task.spawn(function()
			task.wait(0.5)
			teleportToRandomServer()
		end)
	end
end)

local lastHeartbeat = tick()
RunService.Heartbeat:Connect(function()
	lastHeartbeat = tick()
end)

task.spawn(function()
	while task.wait(5) do
		if tick() - lastHeartbeat > 10 then
			MakeNotif("Connection Issue", "Heartbeat timeout, attempting to reconnect...", 5, Color3.fromRGB(255,165,0))
			teleportToRandomServer()
			break
		end
	end
end)

task.delay(2.5,function()
	pcall(function()
		local t=Players.LocalPlayer.PlayerGui:WaitForChild("RoundTimer").Main.Time.ContentText
		local m,s=t:match("(%d+):(%d+)")
		local total=tonumber(m)*60+tonumber(s)
		MakeNotif("Round ends in",total.." seconds",5,Color3.fromRGB(115,194,89))
		if total>90 then teleportToRandomServer() end
	end)
end)

local knownGeneratorPositions = {}

local function findGenerators()
	local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
	local map = folder and folder:FindFirstChild("Map")
	local generators = {}
	if map then
		for _, g in ipairs(map:GetChildren()) do
			if g.Name == "Generator" then
				local pos = g:GetPivot().Position
				local posKey = string.format("%.1f_%.1f_%.1f", pos.X, pos.Y, pos.Z)
				knownGeneratorPositions[posKey] = {
					position = pos,
					cframe = g:GetPivot(),
					generator = g
				}

				if g.Progress.Value < 100 then
					local playersNearby = false
					for _, player in ipairs(Players:GetPlayers()) do
						if player ~= Players.LocalPlayer and player:DistanceFromCharacter(pos) <= 25 then
							playersNearby = true
						end
					end
					if not playersNearby then
						table.insert(generators, g)
					end
				end
			end
		end
	end
	return generators
end

local function areAllGeneratorsCompleted()
	local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
	local map = folder and folder:FindFirstChild("Map")
	if map then
		for _, g in ipairs(map:GetChildren()) do
			if g.Name == "Generator" and g.Progress.Value < 100 then
				return false
			end
		end
	end
	return true
end

local function countRemainingGenerators()
	local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
	local map = folder and folder:FindFirstChild("Map")
	local count = 0
	if map then
		for _, g in ipairs(map:GetChildren()) do
			if g.Name == "Generator" and g.Progress.Value < 100 then
				count = count + 1
			end
		end
	end
	return count
end

local function GetFurthestSafePosition(killerPosition)
	local furthest = nil
	local maxDistance = 0
	local char = Players.LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
	
	for _, genData in pairs(knownGeneratorPositions) do
		local distFromKiller = (genData.position - killerPosition).Magnitude
		if distFromKiller > maxDistance then
			furthest = genData
			maxDistance = distFromKiller
		end
	end
	
	return furthest
end

local function GetFurthestGenerator()
	local furthest, maxDistance = nil, 0
	if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local myPos = Players.LocalPlayer.Character.HumanoidRootPart.Position
		for _, g in ipairs(findGenerators()) do
			local dist = (g:GetPivot().Position - myPos).Magnitude
			if dist > maxDistance then
				furthest = g
				maxDistance = dist
			end
		end
	end
	return furthest
end

local function CheckNearbyKillerAndRun()
	while task.wait(0.5) do
		if #workspace.Players:WaitForChild("Killers"):GetChildren() >= 1 then
			for _, killer in ipairs(workspace.Players.Killers:GetChildren()) do
				local char = Players.LocalPlayer.Character
				if char and char:FindFirstChild("HumanoidRootPart") and killer:FindFirstChild("HumanoidRootPart") then
					local dist = (killer.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
					if dist <= 50 then
						local killerPos = killer.HumanoidRootPart.Position
						
						local safestSpot = GetFurthestSafePosition(killerPos)
						if safestSpot then
							local safePos = safestSpot.cframe * CFrame.new(0, 0, -3)
                            char.HumanoidRootPart.CFrame = safePos
							local distance = math.floor((safestSpot.position - killerPos).Magnitude)
							MakeNotif("Smart Escape!", string.format("Escaped to position %d studs from killer!", distance), 5, Color3.fromRGB(0, 255, 255))
						else
							local furthestGen = GetFurthestGenerator()
							if furthestGen then
								char.HumanoidRootPart.CFrame = furthestGen:GetPivot() * CFrame.new(furthestGen:GetPivot().LookVector * Vector3.new(3,0,3))
								MakeNotif("Warning", "Killer nearby! Teleported to furthest generator.", 5, Color3.fromRGB(255, 100, 100))
							end
						end
					end
				end
			end
		end
	end
end

local function InGenerator()
	for i, v in ipairs(game:GetService("Players").LocalPlayer.PlayerGui.TemporaryUI:GetChildren()) do
		if string.sub(v.Name, 1, 3) == "Gen" then
			return false
		end
	end
	return true
end

local function DoAllGenerators()
	MakeNotif("Mapping", "Scanning all generator positions...", 3, Color3.fromRGB(100, 150, 255))
	findGenerators() 
	
	local totalPositions = 0
	for _ in pairs(knownGeneratorPositions) do
		totalPositions = totalPositions + 1
	end
	MakeNotif("Map Complete", string.format("Saved %d generator positions!", totalPositions), 3, Color3.fromRGB(0, 255, 100))
	
	while not areAllGeneratorsCompleted() do
		local availableGens = findGenerators()
		
		if #availableGens == 0 then
			task.wait(1)
			continue
		end
		
		for _,g in ipairs(availableGens) do
			if g.Progress.Value >= 100 then
				continue
			end
			
			if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				Players.LocalPlayer.Character.HumanoidRootPart.CFrame = g:GetPivot() * CFrame.new(0, 0, -3)
				VisualizePivot(g)
				task.wait(0.5)
				local prompt=g:FindFirstChild("Main") and g.Main:FindFirstChild("Prompt")
				if prompt then
					fireproximityprompt(prompt)
					task.wait(0.5)
					if not InGenerator() then
						for _,pos in ipairs({g:GetPivot().Position - g:GetPivot().RightVector*3, g:GetPivot().Position + g:GetPivot().RightVector*3}) do
							Players.LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(pos)
							task.wait(1)
							fireproximityprompt(prompt)
							if InGenerator() then break end
						end
					end
				end
				for i=1,6 do
					if g.Progress.Value<100 and g:FindFirstChild("Remotes") and g.Remotes:FindFirstChild("RE") then
						g.Remotes.RE:FireServer()
					end
					if i<6 and g.Progress.Value<100 then task.wait(GenTime) end
				end
			end
		end
		
		task.wait(0.5)
	end
	
	MakeNotif("Success!", "All generators completed! Teleporting to new server...", 5, Color3.fromRGB(0, 255, 0))
	
	SendWebhook(
		"Generator Autofarm",
		"Finished all generators, Current Balance: "
			.. game:GetService("Players").LocalPlayer.PlayerData.Stats.Currency.Money.Value
			.. "\nTime Played: "
			.. (function()
				local seconds = game:GetService("Players").LocalPlayer.PlayerData.Stats.General.TimePlayed.Value
				local days = math.floor(seconds / (60 * 60 * 24))
				seconds = seconds % (60 * 60 * 24)
				local hours = math.floor(seconds / (60 * 60))
				seconds = seconds % (60 * 60)
				local minutes = math.floor(seconds / 60)
				seconds = seconds % 60
				return string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
			end)(),
		0x00FF00,
		ProfilePicture,
		"Crystal Hub 😏"
	)
	task.wait(1)
	teleportToRandomServer()
end

local function HandleInvisibility(active)
	local char = Players.LocalPlayer.Character
	if char and active and char.Parent ~= workspace.Players.Spectating then
		local anim = Instance.new("Animation")
		anim.Name = "HWID_" .. gethwid()
		anim.AnimationId = "rbxassetid://75804462760596"

		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			local track = hum:LoadAnimation(anim)
			track:Play(0, 1, 1)
			track:AdjustSpeed(0)
		end
	elseif char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
				if track.Animation and track.Animation.Name == "HWID_" .. gethwid() then
					track:Stop()
				end
			end
		end
	end
end



local function AmIInGameYet()
	workspace.Players.Survivors.ChildAdded:Connect(function(child)
		task.wait(1)
		if child == game:GetService("Players").LocalPlayer.Character then
			task.wait(4)
			HandleInvisibility(true)
		    pcall(task.spawn, DidiDie)
            CheckNearbyKillerAndRun()
			DoAllGenerators()
		end
	end)
end


local function DidiDie()
	while task.wait(0.5) do
		if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			if Players.LocalPlayer.Character.Humanoid.Health==0 then
				SendWebhook(
					"Generator Autofarm",
					"Mày bị killer hấp dim rồi\nCurrent Balance: "
						.. game:GetService("Players").LocalPlayer.PlayerData.Stats.Currency.Money.Value
						.. "\nTime Played: "
						.. (function()
							local seconds =
								game:GetService("Players").LocalPlayer.PlayerData.Stats.General.TimePlayed.Value
							local days = math.floor(seconds / (60 * 60 * 24))
							seconds = seconds % (60 * 60 * 24)
							local hours = math.floor(seconds / (60 * 60))
							seconds = seconds % (60 * 60)
							local minutes = math.floor(seconds / 60)
							seconds = seconds % 60
							return string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
						end)(),
					0xFF0000,
					ProfilePicture,
					"Crystal Hub 😏"
				)
				task.wait(0.5)
				teleportToRandomServer()
				break
			end
		end
	end
end

startDetection()
AmIInGameYet()

Players.LocalPlayer.CharacterAdded:Connect(function()
	ultraInstinctEnabled = true
	startDetection() 

end)
