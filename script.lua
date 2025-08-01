if getgenv and tonumber(getgenv().LoadTime) then
	task.wait(tonumber(getgenv().LoadTime))
else
	repeat task.wait() until game:IsLoaded()
end

local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local DCWebhook = (getgenv and getgenv().DiscordWebhook) or false
local GenTime = tonumber(getgenv and getgenv().GeneratorTime) or 2.5
local NotificationGui
local Notifications = {}
local ProfilePicture = ""

local function CreateNotificationUI()
	if NotificationGui then return NotificationGui end
	NotificationGui = Instance.new("ScreenGui")
	NotificationGui.Name = "NotificationUI"
	NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	NotificationGui.Parent = game:GetService("CoreGui")
	return NotificationGui
end

local function MakeNotif(title, message, duration, color)
	local ui = CreateNotificationUI()
	duration = duration or 5
	color = color or Color3.fromRGB(255, 200, 0)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 250, 0, 80)
	frame.Position = UDim2.new(1, 50, 1, 10)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = ui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = title or "Notification"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = color
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -25, 0, 25)
	titleLabel.Position = UDim2.new(0, 15, 0, 5)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = frame
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Text = message or ""
	messageLabel.Font = Enum.Font.SourceSans
	messageLabel.TextSize = 16
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Size = UDim2.new(1, -25, 0, 50)
	messageLabel.Position = UDim2.new(0, 15, 0, 30)
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextWrapped = true
	messageLabel.Parent = frame
	local colorBar = Instance.new("Frame")
	colorBar.Size = UDim2.new(0, 5, 1, 0)
	colorBar.Position = UDim2.new(0, 0, 0, 0)
	colorBar.BackgroundColor3 = color
	colorBar.BorderSizePixel = 0
	colorBar.Parent = frame
	local offsit = 0
	for _, notif in pairs(Notifications) do
		if notif.Instance and notif.Instance.Parent then
			offsit = offsit + notif.Instance.Size.Y.Offset + 10
		end
	end
	local goalPos = UDim2.new(1, -270, 1, -90 - offsit)
	frame.Position = UDim2.new(1, 50, 1, 10)
	table.insert(Notifications, {
		Instance = frame,
		ExpireTime = os.time() + duration,
	})
	local tweenIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = goalPos })
	tweenIn:Play()
	task.spawn(function()
		task.wait(duration)
		local tweenOut = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 50, frame.Position.Y.Scale, frame.Position.Y.Offset) })
		tweenOut:Play()
		tweenOut.Completed:Wait()
		for i, notif in pairs(Notifications) do
			if notif.Instance == frame then
				table.remove(Notifications, i)
				break
			end
		end
		frame:Destroy()
		task.wait()
		local currentOffset = 0
		for _, notif in pairs(Notifications) do
			if notif.Instance and notif.Instance.Parent then
				TweenService:Create(notif.Instance, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(1, -270, 1, -90 - currentOffset) }):Play()
				currentOffset = currentOffset + notif.Instance.Size.Y.Offset + 10
			end
		end
	end)
	return frame
end

local function GetProfilePicture()
	local PlayerID = Players.LocalPlayer.UserId
	local request = request or http_request or syn.request
	local success, response = pcall(function()
		return request({
			Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..PlayerID.."&size=180x180&format=png",
			Method = "GET",
			Headers = { ["User-Agent"] = "Mozilla/5.0" }
		})
	end)
	if success and response and response.Body then
		local urlStart, urlEnd = string.find(response.Body, "https://[%w-_%.%?%.:/%+=&]+")
		if urlStart and urlEnd then
			ProfilePicture = string.sub(response.Body, urlStart, urlEnd)
		else
			ProfilePicture = "https://cdn.sussy.dev/bleh.jpg"
		end
	else
		ProfilePicture = "https://cdn.sussy.dev/bleh.jpg"
	end
end

if DCWebhook then
	GetProfilePicture()
end

local function SendWebhook(Title, Description, Color, ProfilePicture, Footer)
	if not DCWebhook then return end
	local request = request or http_request or syn.request
	if not request then return end
	pcall(function()
		request({
			Url = DCWebhook,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode({
				username = Players.LocalPlayer.DisplayName,
				avatar_url = ProfilePicture,
				embeds = { {
					title = Title,
					description = Description,
					color = Color,
					footer = { text = Footer }
				} }
			})
		})
	end)
	MakeNotif("Webhook sent", Title .. "\n" .. Description, 5, Color3.fromRGB(115, 194, 89))
end

local function FindNearestKiller()
	local nearestKiller = nil
	local nearestDistance = math.huge
	for _, killer in ipairs(workspace.Players.Killers:GetChildren()) do
		if killer:FindFirstChild("HumanoidRootPart") then
			local dist = (killer.HumanoidRootPart.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if dist < nearestDistance then
				nearestDistance = dist
				nearestKiller = killer
			end
		end
	end
	return nearestKiller, nearestDistance
end

local function TeleportToSafeGenerator()
	local gens = {}
	local char = Players.LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart
	local mapFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map")
	if not mapFolder then return end
	for _, g in ipairs(mapFolder:GetChildren()) do
		if g.Name == "Generator" and g.Progress.Value < 100 then
			table.insert(gens, g)
		end
	end
	if #gens == 0 then return end
	table.sort(gens, function(a, b)
		return (hrp.Position - a:GetPivot().Position).Magnitude > (hrp.Position - b:GetPivot().Position).Magnitude
	end)
	local targetGen = gens[1]
	if targetGen and targetGen.Parent then
		hrp.CFrame = CFrame.new(targetGen:GetPivot().Position + Vector3.new(0, 5, 0))
		MakeNotif("Teleport", "Đã teleport đến generator xa nhất để tránh killer", 5, Color3.fromRGB(255, 0, 0))
	end
end

local function AutoJumpIfKillerNear()
	local killer, dist = FindNearestKiller()
	if killer and dist <= 60 then
		local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
			humanoid.Jump = true
		end
	end
end

local function findGenerators()
	local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map")
	local generators = {}
	if folder then
		for _, gen in ipairs(folder:GetChildren()) do
			if gen.Name == "Generator" and gen.Progress.Value < 100 then
				table.insert(generators, gen)
			end
		end
	end
	return generators
end

local function doAllGenerators()
	local char = Players.LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then
		MakeNotif("Lỗi", "Không tìm thấy HumanoidRootPart!", 5, Color3.fromRGB(255, 0, 0))
		return false
	end
	local hrp = char.HumanoidRootPart
	while true do
		local gens = findGenerators()
		if #gens == 0 then
			MakeNotif("Thông báo", "Không còn generator để sửa!", 5, Color3.fromRGB(255, 255, 0))
			return true
		end
		for i, gen in ipairs(gens) do
			local killer, dist = FindNearestKiller()
			if killer and dist <= 60 then
				MakeNotif("Killer gần!", "Teleport đến generator xa hơn để an toàn", 5, Color3.fromRGB(255, 0, 0))
				TeleportToSafeGenerator()
				return false
			end
			hrp.CFrame = CFrame.new(gen:GetPivot().Position + Vector3.new(0, 5, 0))
			MakeNotif("Sửa generator", "Đang sửa generator #" .. i, 5, Color3.fromRGB(115, 194, 89))
			local prompt = gen:FindFirstChild("Main") and gen.Main:FindFirstChild("Prompt")
			if prompt then
				fireproximityprompt(prompt)
			end
			local startTime = tick()
			while gen.Progress.Value < 100 do
				AutoJumpIfKillerNear()
				local killerNow, distNow = FindNearestKiller()
				if killerNow and distNow <= 60 then
					MakeNotif("Killer lại gần!", "Dừng sửa và teleport an toàn", 5, Color3.fromRGB(255, 0, 0))
					TeleportToSafeGenerator()
					return false
				end
				if prompt then
					fireproximityprompt(prompt)
				end
				task.wait(GenTime)
				if tick() - startTime > 60 then
					break
				end
			end
			MakeNotif("Hoàn thành", "Đã sửa xong generator #" .. i, 5, Color3.fromRGB(0, 255, 0))
		end
	end
end

local function teleportToRandomServer()
	local Counter = 0
	local MaxRetry = 10
	local RetryDelay = 10
	local Request = http_request or syn.request or request
	if not Request then return end
	local url = "https://games.roblox.com/v1/games/18687417158/servers/Public?sortOrder=Asc&limit=100"
	while Counter < MaxRetry do
		local success, response = pcall(function()
			return Request({
				Url = url,
				Method = "GET",
				Headers = { ["Content-Type"] = "application/json" }
			})
		end)
		if success and response and response.Body then
			local data = HttpService:JSONDecode(response.Body)
			if data and data.data and #data.data > 0 then
				local candidates = {}
				for _, server in ipairs(data.data) do
					if server.playing and server.maxPlayers then
						if server.playing < (server.maxPlayers * 0.4) then
							table.insert(candidates, server)
						end
					else
						table.insert(candidates, server)
					end
				end
				if #candidates == 0 then
					candidates = data.data
				end
				local server = candidates[math.random(1, #candidates)]
				if server and server.id then
					MakeNotif("Teleporting...", "Đang teleport đến server " .. server.id, 5, Color3.fromRGB(115, 194, 89))
					task.wait(0.25)
					TeleportService:TeleportToPlaceInstance(18687417158, server.id, Players.LocalPlayer)
					return
				end
			end
		end
		Counter = Counter + 1
		MakeNotif("Retrying", "Thử lại lần " .. Counter .. "/" .. MaxRetry, 5, Color3.fromRGB(255, 0, 0))
		task.wait(RetryDelay)
	end
end

task.spawn(function()
	while true do
		task.wait(10)
		local timerGui = Players.LocalPlayer.PlayerGui:FindFirstChild("RoundTimer")
		if timerGui then
			local timeLabel = timerGui.Main:FindFirstChild("Time")
			if timeLabel then
				local textLabel = timeLabel:FindFirstChild("ContentText")
				if textLabel then
					local timeText = textLabel.Text or ""
					if timeText == "0:00" or timeText == "0:01" then
						MakeNotif("Round kết thúc", "Chuẩn bị hop server...", 5, Color3.fromRGB(255, 200, 0))
						teleportToRandomServer()
						break
					end
				end
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(0.5)
		local char = Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			if char.Humanoid.Health <= 0 then
				SendWebhook(
					"Generator Autofarm",
					"Bạn đã chết! \nTiền hiện tại: " .. tostring(Players.LocalPlayer.PlayerData.Stats.Currency.Money.Value),
					0xFF0000,
					ProfilePicture,
					"AutoHop by script"
				)
				task.wait(3)
				teleportToRandomServer()
				break
			end
		end
	end
end)

task.spawn(function()
	while true do
		local success = doAllGenerators()
		if not success then
			task.wait(5)
		end
		task.wait(0.5)
	end
end)
