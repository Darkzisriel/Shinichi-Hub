-- Load waiting
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

local DCWebhook = (getgenv and getgenv().DiscordWebhook) or false
local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5

local AliveNotificaiotna, Nnnnnnotificvationui, ProfilePicture = {}, nil, ""
if DCWebhook == "" then DCWebhook = false end

-- Notification System
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

-- Notification cleanup
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

MakeNotif("Strawberry Cat Hub", "Script Loaded!", 5, Color3.fromRGB(115, 194, 89))

-- Disable Malice
task.spawn(function()
	pcall(function()
		game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer(
			"UpdateSettings",
			game:GetService("Players").LocalPlayer.PlayerData.Settings.Game.MaliceDisabled,
			true
		)
	end)
end)

-- Ultra Instinct System - Killer animation IDs
local killerAnims = {
	"126830014841198", "126355327951215", "121086746534252", "18885909645",
	"98456918873918", "105458270463374", "83829782357897", "125403313786645",
	"118298475669935", "82113744478546", "70371667919898", "99135633258223",
	"97167027849946", "109230267448394", "139835501033932", "126896426760253",
	"109667959938617", "126681776859538", "129976080405072", "121293883585738"
}

local directions = {"Left", "Right", "Forward", "Backward"}
local currentDirection = 1
local ultraInstinctEnabled = true -- Luôn bật
local canDodge = true
local lastNotifTime = 0
local notifCooldown = 2
local dodgeDistance = 9 -- Khoảng cách cố định

-- Animations
local dodgeAnims = {
	Left = "rbxassetid://17096325697",
	Right = "rbxassetid://17096327600",
	Forward = "rbxassetid://17096329187",
	Backward = "rbxassetid://17096330733",
}

-- Notify
local function notify(msg)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Crystal Hub",
			Text = msg,
			Duration = 2
		})
	end)
end

-- Dodge logic
local function playDodge()
	if not canDodge then return end
	canDodge = false

	local char = lp.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	local dir = directions[currentDirection]
	local offset = Vector3.new()
	if dir == "Left" then
		offset = -hrp.CFrame.RightVector * dodgeDistance
	elseif dir == "Right" then
		offset = hrp.CFrame.RightVector * dodgeDistance
	elseif dir == "Forward" then
		offset = hrp.CFrame.LookVector * dodgeDistance
	elseif dir == "Backward" then
		offset = -hrp.CFrame.LookVector * dodgeDistance
	end

	-- Play animation
	local anim = Instance.new("Animation")
	anim.AnimationId = dodgeAnims[dir]
	local track = hum:LoadAnimation(anim)
	track:Play()

	-- Move player
	char:PivotTo(CFrame.new(hrp.Position + offset))

	-- Reset cooldown
	task.delay(0.1, function()
		canDodge = true
	end)
end

-- Detection
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

-- Stop Detection
local function stopDetection()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

-- Profile Picture
local function GetProfilePicture()
	local PlayerID = Players.LocalPlayer.UserId
	local req = request or http_request or syn.request
	local res = req({Url="https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..PlayerID.."&size=180x180&format=png",Method="GET"})
	local start, end_ = string.find(res.Body, "https://[%w-_%.%?%.:/%+=&]+")
	if start and end_ then ProfilePicture = string.sub(res.Body,start,end_) else ProfilePicture = "https://cdn.sussy.dev/bleh.jpg" end
end

if DCWebhook then GetProfilePicture() end

-- Webhook
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

-- Pivot Visualization
local function VisualizePivot(model)
	local pivot = model:GetPivot()
	for i, dir in ipairs({
		{ pivot.LookVector, Color3.fromRGB(0, 255, 0), "Front" },
		{ -pivot.LookVector, Color3.fromRGB(255, 0, 0), "Back" },
		{ pivot.RightVector, Color3.fromRGB(255, 255, 0), "Right" },
		{ -pivot.RightVector, Color3.fromRGB(0, 0, 255), "Left" },
	}) do
		local part = Instance.new("Part")
		part.Size = Vector3.new(1, 1, 1)
		part.Anchored = true
		part.CanCollide = false
		part.Color = dir[2]
		part.Name = dir[3]
		part.Position = pivot.Position + dir[1] * 5
		part.Parent = workspace
	end
end

-- Server hopping
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

-- Error handling
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
	MakeNotif("Teleport Failed", tostring(errorMessage or teleportResult), 5, Color3.fromRGB(255,0,0))
	task.wait(1)
	teleportToRandomServer()
end)

game.CoreGui.ChildAdded:Connect(function(child)
	if child:IsA("ScreenGui") and (string.find(child.Name:lower(), "kick") or string.find(child.Name:lower(), "error")) then
		MakeNotif("Kicked or Error", "Retrying...", 5, Color3.fromRGB(255,0,0))
		task.wait(2)
		teleportToRandomServer()
	end
end)

-- Round timer check
task.delay(2.5,function()
	pcall(function()
		local t=Players.LocalPlayer.PlayerGui:WaitForChild("RoundTimer").Main.Time.ContentText
		local m,s=t:match("(%d+):(%d+)")
		local total=tonumber(m)*60+tonumber(s)
		MakeNotif("Round ends in",total.." seconds",5,Color3.fromRGB(115,194,89))
		if total>90 then teleportToRandomServer() end
	end)
end)

-- Generator functions
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
	return generators
end

-- Check if all generators are completed
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

-- Count remaining generators
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

-- Enhanced killer avoidance with height check
local function CheckNearbyKillerAndRun()
	while task.wait(0.5) do
		if #workspace.Players:WaitForChild("Killers"):GetChildren() >= 1 then
			for _, killer in ipairs(workspace.Players.Killers:GetChildren()) do
				local char = Players.LocalPlayer.Character
				if char and char:FindFirstChild("HumanoidRootPart") and killer:FindFirstChild("HumanoidRootPart") then
					local dist = (killer.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
					if dist <= 50 then
						local remainingGens = countRemainingGenerators()
						
						-- If only 1 generator left, fly up high
						if remainingGens <= 1 then
							local currentPos = char.HumanoidRootPart.Position
							char.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, currentPos.Y + 20, currentPos.Z)
							MakeNotif("Final Generator!", "Flying high to avoid killer - only 1 gen left!", 5, Color3.fromRGB(255, 165, 0))
						else
							-- Normal behavior - go to furthest generator
							local furthestGen = GetFurthestGenerator()
							if furthestGen then
								char.HumanoidRootPart.CFrame = furthestGen:GetPivot() + furthestGen:GetPivot().LookVector*3
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

-- Enhanced generator automation with completion check
local function DoAllGenerators()
	while not areAllGeneratorsCompleted() do
		local availableGens = findGenerators()
		
		-- If no generators available, wait and check again
		if #availableGens == 0 then
			task.wait(1)
			continue
		end
		
		for _,g in ipairs(availableGens) do
			-- Double check generator still needs completion
			if g.Progress.Value >= 100 then
				continue
			end
			
			if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				Players.LocalPlayer.Character.HumanoidRootPart.CFrame = g:GetPivot()+g:GetPivot().LookVector*3
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
		
		-- Small delay before checking for more generators
		task.wait(0.5)
	end
	
	-- All generators completed
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
		"Strawberry Cat Hub :smirk:"
	)
	task.wait(1)
	teleportToRandomServer()
end

-- Invisibility
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

-- Game start detection
local function AmIInGameYet()
	workspace.Players.Survivors.ChildAdded:Connect(function(child)
		task.wait(1)
		if child == game:GetService("Players").LocalPlayer.Character then
			task.wait(4)
			HandleInvisibility(true)
			DoAllGenerators()
		end
	end)
end

-- Death detection
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
					"Strawberry Cat Hub :smirk:"
				)
				task.wait(0.5)
				teleportToRandomServer()
				break
			end
		end
	end
end

-- Initialize Ultra Instinct
startDetection()

-- Start background tasks
pcall(task.spawn, DidiDie)
pcall(task.spawn, CheckNearbyKillerAndRun)
AmIInGameYet()

-- Character respawn handler
Players.LocalPlayer.CharacterAdded:Connect(function()
	ultraInstinctEnabled = true
	startDetection() -- Restart detection on respawn
end)
