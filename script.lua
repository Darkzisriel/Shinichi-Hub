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

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 24, 0, 24)
	icon.Position = UDim2.new(0, 5, 0, 5)
	icon.BackgroundTransparency = 1
	icon.Image = ProfilePicture or "rbxasset://textures/ui/GuiImagePlaceholder.png"
	icon.Parent = notification

	local SIGMABERFIOENEW = Instance.new("TextLabel")
	SIGMABERFIOENEW.Name = "Title"
	SIGMABERFIOENEW.Size = UDim2.new(1, -35, 0, 25)
	SIGMABERFIOENEW.Position = UDim2.new(0, 34, 0, 5)
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
	table.insert(AliveNotificaiotna, { Instance = notification, ExpireTime = os.time() + duration })
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	game:GetService("TweenService"):Create(notification, tweenInfo, { Position = tagit }):Play()
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
				game:GetService("TweenService"):Create(
					notif.Instance,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Position = UDim2.new(1, -270, 1, -90 - currentOffset) }
				):Play()
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

MakeNotif("Strawberry Cat Hub", "Script Loaded!", 5, Color3.fromRGB(115, 194, 89))

local function GetProfilePicture()
	local PlayerID = Players.LocalPlayer.UserId
	local request = request or http_request or syn.request
	local response = request({
		Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. PlayerID .. "&size=180x180&format=png",
		Method = "GET",
		Headers = { ["User-Agent"] = "Mozilla/5.0" },
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
	if not DCWebhook then return end
	local request = request or http_request or syn.request
	pcall(function()
		request({
			Url = DCWebhook,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode({
				username = Players.LocalPlayer.DisplayName,
				avatar_url = ProfilePicture,
				embeds = { { title = Title, description = Description, color = Color, footer = { text = Footer } } },
			}),
		})
	end)
	MakeNotif("Webhook", "Sent: " .. Title .. "\n" .. Description, 5, Color3.fromRGB(115, 194, 89))
end

local function VisualizePivot(model)
	local pivot = model:GetPivot()
	for _, dir in ipairs({
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
		part.Parent = workspace
	end
end

local function TeleportToGenerator(generator)
	if not generator or not generator.Parent then return false end
	if not Players.LocalPlayer.Character or not Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
	local rootPart = Players.LocalPlayer.Character.HumanoidRootPart
	local targetPosition = generator:GetPivot().Position + generator:GetPivot().LookVector * 3
	VisualizePivot(generator)
	rootPart.CFrame = CFrame.new(targetPosition)
	task.wait(0.3)
	if (rootPart.Position - targetPosition).Magnitude <= 5 then
		return true
	else
		return false
	end
end

local function findGenerators()
	local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
	local map = folder and folder:FindFirstChild("Map")
	local generators = {}
	if map then
		for _, g in ipairs(map:GetChildren()) do
			if g.Name == "Generator" and g.Progress.Value < 100 then
				table.insert(generators, g)
			end
		end
	end
	table.sort(generators, function(a, b)
		local p = Players.LocalPlayer
		local c = p.Character
		if not c or not c:FindFirstChild("HumanoidRootPart") then return false end
		return (a:GetPivot().Position - c.HumanoidRootPart.Position).Magnitude < (b:GetPivot().Position - c.HumanoidRootPart.Position).Magnitude
	end)
	return generators
end

local function InGenerator()
	for _, v in ipairs(Players.LocalPlayer.PlayerGui.TemporaryUI:GetChildren()) do
		if string.sub(v.Name,1,3)=="Gen" then
			return false
		end
	end
	return true
end

local function DoAllGenerators()
	for _, g in ipairs(findGenerators()) do
		local ok = false
		for i=1,3 do
			if (Players.LocalPlayer.Character:GetPivot().Position - g:GetPivot().Position).Magnitude>500 then break end
			ok = TeleportToGenerator(g)
			if ok then break else task.wait(1) end
		end
		if ok then
			task.wait(0.5)
			local prompt = g:FindFirstChild("Main") and g.Main:FindFirstChild("Prompt")
			if prompt then
				fireproximityprompt(prompt)
				task.wait(0.5)
				if not InGenerator() then
					local positions={g:GetPivot().Position-g:GetPivot().RightVector*3,g:GetPivot().Position+g:GetPivot().RightVector*3}
					for _,pos in ipairs(positions) do
						Players.LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(pos)
						task.wait(0.25)
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
		else
			return
		end
	end
	SendWebhook("Generator Autofarm","Finished all generators.",0x00FF00,ProfilePicture,".gg/CEyArUEnNW | By Darkz X Shinichi")
	task.wait(1)
end

local function AmIInGameYet()
	workspace.Players.Survivors.ChildAdded:Connect(function(child)
		task.wait(1)
		if child==Players.LocalPlayer.Character then
			task.wait(4)
			DoAllGenerators()
		end
	end)
end

AmIInGameYet()
