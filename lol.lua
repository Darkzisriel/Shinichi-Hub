-- == CONFIG ==
local DiscordWebhook = "https://discord.com/api/webhooks/1400382842894159923/XIjGfYweEPlkU6VERCzil1lQbFfwKwbxfibXzTryFZu0I3tr4k5KuvwDcPKJhphgpHzH" -- Thay bằng webhook của bạn hoặc để false
local GeneratorTime = 2.5 -- Thời gian giữa các lần sửa generator

-- == SERVICES ==
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")

-- == VARIABLES ==
local LocalPlayer = Players.LocalPlayer
local Humanoid, RootPart
local busy = false
local ActiveInfiniteStamina = true
local ProfilePicture = ""
local AliveNotifications = {}

-- == FUNCTIONS ==

-- Tạo popup thông báo
local function CreateNotificationUI()
	local ui = Instance.new("ScreenGui")
	ui.Name = "NotificationUI"
	ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ui.Parent = game:GetService("CoreGui")
	return ui
end

local function MakeNotif(title, message, duration, color)
	duration = duration or 5
	color = color or Color3.fromRGB(255, 200, 0)
	local ui = CreateNotificationUI()
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(0, 250, 0, 80)
	notification.Position = UDim2.new(1, 50, 1, 10)
	notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	notification.BorderSizePixel = 0
	notification.Parent = ui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notification

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -25, 0, 25)
	titleLabel.Position = UDim2.new(0, 15, 0, 5)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.Text = title
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = color
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notification

	local messageLabel = Instance.new("TextLabel")
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
	colorBar.Size = UDim2.new(0, 5, 1, 0)
	colorBar.Position = UDim2.new(0, 0, 0, 0)
	colorBar.BackgroundColor3 = color
	colorBar.BorderSizePixel = 0
	colorBar.Parent = notification

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 8)
	barCorner.Parent = colorBar

	table.insert(AliveNotifications, notification)

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tween = game:GetService("TweenService"):Create(notification, tweenInfo, { Position = UDim2.new(1, -270, 1, -90) })
	tween:Play()

	task.spawn(function()
		task.wait(duration)
		local tweenOut = game:GetService("TweenService"):Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 50, notification.Position.Y.Scale, notification.Position.Y.Offset) })
		tweenOut:Play()
		tweenOut.Completed:Wait()
		notification:Destroy()
	end)

	return notification
end

-- Lấy ảnh profile Roblox (dùng webhook)
local function GetProfilePicture()
	local playerId = LocalPlayer.UserId
	local req = request or http_request or syn.request
	if not req then return end

	pcall(function()
		local res = req({
			Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. playerId .. "&size=180x180&format=png",
			Method = "GET",
			Headers = { ["User-Agent"] = "Mozilla/5.0" },
		})
		if res and res.Body then
			local startPos, endPos = string.find(res.Body, "https://[%w-_%.%?%.:/%+=&]+")
			if startPos and endPos then
				ProfilePicture = string.sub(res.Body, startPos, endPos)
			end
		end
	end)
end

-- Gửi webhook
local function SendWebhook(title, description, color)
	if not DiscordWebhook then return end
	local req = request or http_request or syn.request
	if not req then return end

	pcall(function()
		req({
			Url = DiscordWebhook,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode({
				username = LocalPlayer.DisplayName,
				avatar_url = ProfilePicture,
				embeds = {{
					title = title,
					description = description,
					color = color or 0x00FF00,
				}},
			}),
		})
	end)
end

-- Teleport server ngẫu nhiên khác server hiện tại
local function teleportToRandomServer()
	local maxRetries = 10
	local retries = 0
	local req = request or http_request or syn.request
	if not req then return end

	local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"

	while retries < maxRetries do
		local success, response = pcall(function()
			return req({
				Url = url,
				Method = "GET",
				Headers = { ["Content-Type"] = "application/json" }
			})
		end)
		if success and response and response.Body then
			local data = HttpService:JSONDecode(response.Body)
			if data and data.data and #data.data > 0 then
				local server = data.data[math.random(1, #data.data)]
				if server and server.id and server.id ~= game.JobId then
					SendWebhook("Teleporting to new server", "Teleporting to server ID: " .. server.id, 0x00FF00)
					MakeNotif("Teleport", "Teleporting to new server...", 5, Color3.fromRGB(115, 194, 89))
					TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
					return
				end
			end
		end
		retries = retries + 1
		task.wait(2)
	end
	warn("Failed to find a new server to teleport after " .. maxRetries .. " retries.")
end

-- Tìm tất cả generator chưa hoàn thành và không có người gần (25 studs)
local function findGenerators()
	local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
	local map = folder and folder:FindFirstChild("Map")
	local generators = {}
	if map then
		for _, g in ipairs(map:GetChildren()) do
			if g.Name == "Generator" and g.Progress.Value < 100 then
				local playersNearby = false
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player:DistanceFromCharacter(g:GetPivot().Position) <= 25 then
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
		local character = LocalPlayer.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
		local rootPart = character.HumanoidRootPart
		local aPos = a:IsA("Model") and a:GetPivot().Position or a.Position
		local bPos = b:IsA("Model") and b:GetPivot().Position or b.Position
		return (aPos - rootPart.Position).Magnitude < (bPos - rootPart.Position).Magnitude
	end)
	return generators
end

-- Tìm generator xa nhất trong danh sách (dùng cho chạy khi killer tới gần hoặc teleport máu thấp)
local function findFarthestGenerator()
	local generators = findGenerators()
	if #generators == 0 then return nil end
	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
	local rootPart = character.HumanoidRootPart
	table.sort(generators, function(a, b)
		local aPos = a:IsA("Model") and a:GetPivot().Position or a.Position
		local bPos = b:IsA("Model") and b:GetPivot().Position or b.Position
		return (aPos - rootPart.Position).Magnitude > (bPos - rootPart.Position).Magnitude
	end)
	return generators[1]
end

-- Visualize các điểm pivot generator (chỉ debug)
local function VisualizePivot(model)
	local pivot = model:GetPivot()
	for i, dir in ipairs({
		{ pivot.LookVector, Color3.fromRGB(0, 255, 0) },
		{ -pivot.LookVector, Color3.fromRGB(255, 0, 0) },
		{ pivot.RightVector, Color3.fromRGB(255, 255, 0) },
		{ -pivot.RightVector, Color3.fromRGB(0, 0, 255) },
	}) do
		local part = Instance.new("Part")
		part.Size = Vector3.new(1, 1, 1)
		part.Anchored = true
		part.CanCollide = false
		part.Color = dir[2]
		part.Position = pivot.Position + dir[1] * 5
		part.Transparency = 0.5
		part.Name = "Viz"
		part.Parent = workspace
		game:GetService("Debris"):AddItem(part, 10)
	end
end

-- Chạy pathfinding đến target
local function PathFinding(targetPos)
	if not LocalPlayer.Character then return false end
	local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return false end

	local path = PathfindingService:CreatePath({
		AgentRadius = 2.5,
		AgentHeight = 5,
		AgentCanJump = false,
		AgentCanClimb = true,
		AgentMaxSlope = 45
	})

	local success, err = pcall(function()
		path:ComputeAsync(rootPart.Position, targetPos)
	end)

	if not success or path.Status ~= Enum.PathStatus.Success then
		warn("Pathfinding failed:", err)
		return false
	end

	local waypoints = path:GetWaypoints()
	for i, waypoint in ipairs(waypoints) do
		humanoid:MoveTo(waypoint.Position)
		local reached = false
		local startTime = tick()
		local conn
		conn = humanoid.MoveToFinished:Connect(function(reachedSuccess)
			reached = reachedSuccess
			conn:Disconnect()
		end)
		repeat task.wait() until reached or tick() - startTime > 10
		if not reached then
			warn("Waypoint timed out, aborting path.")
			return false
		end
	end
	return true
end

-- Kiểm tra xem đang bị stun hay không (busy)
local function CheckBusy()
	return busy
end

-- Bật infinite stamina
local function StartInfiniteStamina()
	task.spawn(function()
		while ActiveInfiniteStamina do
			local sprintModule = require(game.ReplicatedStorage.Systems.Character.Game.Sprinting)
			sprintModule.StaminaLossDisabled = true
			sprintModule.Stamina = 9999999
			task.wait(0.1)
		end
		local sprintModule = require(game.ReplicatedStorage.Systems.Character.Game.Sprinting)
		sprintModule.StaminaLossDisabled = false
		sprintModule.Stamina = 100
	end)
end

-- Sửa generator
local function RepairGenerator(gen)
	if not gen or not gen.Parent then return false end
	local prompt = gen:FindFirstChild("Main") and gen.Main:FindFirstChild("Prompt")
	if not prompt then
		warn("Generator has no prompt!")
		return false
	end
	busy = true
	prompt.HoldDuration = 0
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 99999

	VisualizePivot(gen)
	local rootPart = LocalPlayer.Character.HumanoidRootPart

	local started = PathFinding(gen:GetPivot().Position + gen:GetPivot().LookVector * 3)
	if not started then
		busy = false
		return false
	end

	fireproximityprompt(prompt)
	task.wait(0.5)

	local tries = 0
	while gen.Progress.Value < 100 do
		if tries >= 10 then
			warn("Repair timeout")
			break
		end
		fireproximityprompt(prompt)
		if gen:FindFirstChild("Remotes") and gen.Remotes:FindFirstChild("RE") then
			gen.Remotes.RE:FireServer()
		end
		task.wait(GeneratorTime)
		tries = tries + 1
		if not LocalPlayer.Character or LocalPlayer.Character.Humanoid.Health <= 0 then
			busy = false
			return false
		end
	end
	busy = false
	return true
end

-- Hàm chạy tự động fix all generator
local function DoAllGenerators()
	local gens = findGenerators()
	for _, gen in ipairs(gens) do
		if CheckBusy() then
			MakeNotif("Busy", "Currently busy, waiting...", 3, Color3.fromRGB(255, 100, 100))
			repeat task.wait(1) until not CheckBusy()
		end

		-- Nếu dưới 50 máu thì teleport sang generator xa nhất luôn
		if LocalPlayer.Character.Humanoid.Health < 50 then
			MakeNotif("Low HP", "Health < 50, teleporting to farthest generator", 5, Color3.fromRGB(255, 0, 0))
			local farGen = findFarthestGenerator()
			if farGen then
				LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(farGen:GetPivot().Position)
				task.wait(2)
			end
		end

		local repaired = RepairGenerator(gen)
		if not repaired then
			MakeNotif("Failed", "Failed to repair generator, retrying...", 3, Color3.fromRGB(255, 100, 100))
			task.wait(2)
		end
	end

	SendWebhook("Finished all generators", "Money: " .. tostring(LocalPlayer.PlayerData.Stats.Currency.Money.Value), 0x00FF00)
	MakeNotif("Done", "Finished all generators, teleporting to new server...", 5, Color3.fromRGB(115, 194, 89))
	task.wait(1)
	teleportToRandomServer()
end

-- Hàm chạy khi killer đến gần: chạy sang generator xa nhất
local function OnKillerNearby()
	if CheckBusy() then return end
	local killer = nil
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			-- Ví dụ cách xác định killer: nếu có tag hoặc tên
			if plr.Name == "Killer" or plr:FindFirstChild("KillerTag") then
				killer = plr
				break
			end
		end
	end
	if killer then
		local dist = (killer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
		if dist < 20 then -- killer gần 20 studs
			MakeNotif("Warning!", "Killer nearby! Running to farthest generator...", 5, Color3.fromRGB(255, 0, 0))
			local farGen = findFarthestGenerator()
			if farGen then
				RepairGenerator(farGen) -- Chạy đến và sửa luôn
			else
				MakeNotif("Warning!", "No farthest generator found!", 3, Color3.fromRGB(255, 0, 0))
			end
		end
	end
end

-- Theo dõi killer gần, chạy vòng while
task.spawn(function()
	while true do
		task.wait(2)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			OnKillerNearby()
		end
	end
end)

-- Kiểm tra chết để gửi webhook và teleport lại
local function MonitorDeath()
	while true do
		task.wait(0.5)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
			local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if humanoid.Health <= 0 then
				SendWebhook("Player died", "You have been killed.\nMoney: " .. tostring(LocalPlayer.PlayerData.Stats.Currency.Money.Value), 0xFF0000)
				MakeNotif("You died!", "Teleporting to new server...", 5, Color3.fromRGB(255, 0, 0))
				task.wait(1)
				teleportToRandomServer()
				break
			end
		end
	end
end

task.spawn(MonitorDeath)

-- Bật Infinite stamina
StartInfiniteStamina()

-- Auto start
task.spawn(function()
	while true do
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			DoAllGenerators()
		end
		task.wait(5)
	end
end)
