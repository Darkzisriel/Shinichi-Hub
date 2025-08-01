if getgenv and tonumber(getgenv().LoadTime) then
	task.wait(tonumber(getgenv().LoadTime))
else
	repeat
		task.wait()
	until game:IsLoaded()
end

local VIMVIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DCWebhook = (getgenv and getgenv().DiscordWebhook) or false
local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5

local Nnnnnnotificvationui
local AliveNotificaiotna = {}
local ProfilePicture = ""

if DCWebhook == "" then
	DCWebhook = false
end

-- Notification UI
local function CreateNotificationUI()
	if Nnnnnnotificvationui then
		return Nnnnnnotificvationui
	end

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

MakeNotif("Gen Pathfinding Shit", "It Loaded!", 5, Color3.fromRGB(115, 194, 89))

local function GetProfilePicture()
	local PlayerID = Players.LocalPlayer.UserId
	local request = request or http_request or syn.request
	local response = request({
		Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="
			.. PlayerID
			.. "&size=180x180&format=png",
		Method = "GET",
		Headers = {
			["User-Agent"] = "Mozilla/5.0",
		},
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

local function SendWebhook(Title, Description, Color, ProfilePicture, Footer)
	if not DCWebhook then
		return
	end
	local request = request or http_request or syn.request
	if not request then
		return
	end

	local success, errorMessage = pcall(function()
		local response = request({
			Url = DCWebhook,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode({
				username = Players.LocalPlayer.DisplayName,
				avatar_url = ProfilePicture,
				embeds = {
					{
						title = Title,
						description = Description,
						color = Color,
						footer = { text = Footer },
					},
				},
			}),
		})
		if response and response.Body then
			print(response.Body)
		end
	end)

	MakeNotif("PathfindGens", "Sent webhook: " .. Title .. "\n" .. Description, 5, Color3.fromRGB(115, 194, 89))
	if not success then
		print("Error: " .. errorMessage)
	end
end

-- Disable controls (optional)
pcall(function()
	local Controller =
		require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
	Controller:Disable()
end)

-- Teleport to random server function
local function teleportToRandomServer()
	local Counter = 0
	local MaxRetry = 10
	local RetryingDelays = 10

	local Request = http_request or syn.request or request
	if Request then
		local url = "https://games.roblox.com/v1/games/18687417158/servers/Public?sortOrder=Asc&limit=100"

		while Counter < MaxRetry do
			local success, response = pcall(function()
				return Request({
					Url = url,
					Method = "GET",
					Headers = { ["Content-Type"] = "application/json" },
				})
			end)

			if success and response and response.Body then
				local data = HttpService:JSONDecode(response.Body)
				if data and data.data and #data.data > 0 then
					local server = data.data[math.random(1, #data.data)]
					if server.id then
						MakeNotif(
							"Teleporting...",
							"Attempting to teleport to server: " .. server.id,
							5,
							Color3.fromRGB(115, 194, 89)
						)
						task.wait(0.25)
						TeleportService:TeleportToPlaceInstance(18687417158, server.id, Players.LocalPlayer)
						return
					end
				end
			end

			Counter = Counter + 1
			MakeNotif(
				"PathfindGens",
				"Retrying to get a server... Attempt " .. Counter .. "/" .. MaxRetry,
				5,
				Color3.fromRGB(255, 0, 0)
			)
			task.wait(RetryingDelays)
		end
	end
end

-- Wait 2.5 seconds then check round timer and hop if > 90
task.delay(2.5, function()
	pcall(function()
		local timer = Players.LocalPlayer.PlayerGui:WaitForChild("RoundTimer").Main.Time.ContentText
		local minutes, seconds = timer:match("(%d+):(%d+)")
		local totalSeconds = tonumber(minutes) * 60 + tonumber(seconds)
		print(totalSeconds .. " Left till round end.")
		MakeNotif("PathfindGens", "Round ends in " .. totalSeconds .. " seconds.", 5, Color3.fromRGB(115, 194, 89))
		if totalSeconds > 90 then
			teleportToRandomServer()
		end
	end)
end)

-- Find generators not near players and not finished
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
		local player = Players.LocalPlayer
		local character = player.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			return false
		end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local aPosition = a:IsA("Model") and a:GetPivot().Position or a.Position
		local bPosition = b:IsA("Model") and b:GetPivot().Position or b.Position
		return (aPosition - rootPart.Position).Magnitude < (bPosition - rootPart.Position).Magnitude
	end)

	return generators
end

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

local function InGenerator()
	for i, v in ipairs(Players.LocalPlayer.PlayerGui.TemporaryUI:GetChildren()) do
		if string.sub(v.Name, 1, 3) == "Gen" then
			return false
		end
	end
	return true
end

local function PathFinding(generator)
	local success, _ = pcall(function()
		local a = require(game.ReplicatedStorage.Systems.Character.Game.Sprinting)
		a.StaminaLossDisabled = true
	end)

	local activeNodes = {}

	local function createNode(position)
		local part = Instance.new("Part")
		part.Size = Vector3.new(0.6, 0.6, 0.6)
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(248, 255, 150)
		part.Transparency = 0.5
		part.Anchored = true
		part.CanCollide = false
		part.Position = position + Vector3.new(0, 1.5, 0)
		part.Parent = workspace
		table.insert(activeNodes, part)
		game:GetService("Debris"):AddItem(part, 15)
	end

	if not generator or not generator.Parent then
		return false
	end
	if not Players.LocalPlayer.Character or not Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return false
	end

	local humanoid = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local rootPart = Players.LocalPlayer.Character.HumanoidRootPart
	if not humanoid then
		return false
	end

	local targetPosition = generator:GetPivot().Position + generator:GetPivot().LookVector * 3
	if not targetPosition then
		return false
	end

	VisualizePivot(generator)

	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentJumpHeight = 10,
		AgentCanClimb = true,
		AgentMaxSlope = 45,
	})

	local start = rootPart.Position
	local goal = targetPosition
	path:ComputeAsync(start, goal)

	if path.Status ~= Enum.PathStatus.Success then
		warn("Pathfinding failed")
		return false
	end

	local waypoints = path:GetWaypoints()
	for i, waypoint in ipairs(waypoints) do
		createNode(waypoint.Position)
	end

	for _, waypoint in ipairs(waypoints) do
		humanoid:MoveTo(waypoint.Position)
		local reached = humanoid.MoveToFinished:Wait()
		if not reached then
			warn("Failed to reach waypoint, aborting")
			return false
		end
	end

	task.wait(GenTime)
	return true
end

local function DoAllGenerators()
	local gens = findGenerators()
	if #gens == 0 then
		return false
	end

	for i, gen in ipairs(gens) do
		local success = PathFinding(gen)
		if success then
			local remote = game:GetService("ReplicatedStorage").Events.Interact
			if remote then
				remote:FireServer(gen)
			end
		end
	end
	return true
end

-- RunAwayFromKillers function
local function RunAwayFromKillers()
	local character = Players.LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	for _, killer in ipairs(workspace.Players.Killers:GetChildren()) do
		local kHRP = killer:FindFirstChild("HumanoidRootPart")
		if not kHRP then continue end

		local dist = (kHRP.Position - character.HumanoidRootPart.Position).Magnitude
		if dist <= 100 then
			MakeNotif("Killer nearby!", "Running away from killer...", 5, Color3.fromRGB(255, 50, 50))

			local escapeDirection = -kHRP.CFrame.LookVector.Unit * 50
			local startPos = character.HumanoidRootPart.Position
			local goalPos = startPos + escapeDirection

			local path = PathfindingService:CreatePath({
				AgentRadius = 2,
				AgentHeight = 5,
				AgentCanJump = true,
				AgentJumpHeight = 10,
				AgentCanClimb = true,
				AgentMaxSlope = 45,
			})

			local success, err = pcall(function()
				path:ComputeAsync(startPos, goalPos)
			end)

			if not success or path.Status ~= Enum.PathStatus.Success then
				warn("Pathfinding failed to compute escape path:", err or path.Status)
				return
			end

			local waypoints = path:GetWaypoints()
			for idx, waypoint in ipairs(waypoints) do
				local reached = false
				local reachedConn
				local startTime = os.clock()

				reachedConn = humanoid.MoveToFinished:Connect(function(reachedStatus)
					reached = reachedStatus
					reachedConn:Disconnect()
				end)

				humanoid:MoveTo(waypoint.Position)

				repeat
					task.wait(0.05)
				until reached or (os.clock() - startTime) > 10

				if not reached then
					warn("Failed to reach waypoint, recalculating escape path")
					break
				end
			end
		end
	end
end

-- Main loop
task.spawn(function()
	while true do
		local character = Players.LocalPlayer.Character
		local isInGame = character and character:FindFirstChildOfClass("Humanoid") and character:FindFirstChild("HumanoidRootPart")
		if isInGame then
			RunAwayFromKillers()
			local hasMoreGenerators = DoAllGenerators()
			if not hasMoreGenerators then
				MakeNotif("All generators done", "Hopping server...", 5, Color3.fromRGB(0, 200, 255))
				SendWebhook(
					"PathfindGens",
					"All generators finished. Hopping server...",
					6509979,
					ProfilePicture,
					"PathfindGens"
				)
				task.wait(3)
				teleportToRandomServer()
				break
			end
		else
			MakeNotif("Waiting for character", "Waiting for character to load...", 5, Color3.fromRGB(255, 200, 0))
			task.wait(3)
		end
		task.wait(0.1)
	end
end)
